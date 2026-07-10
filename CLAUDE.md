# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rails 8.1.3 app (Ruby 4.0.5) for tracking personal habits. Uses PostgreSQL with UUID primary keys, Devise for authentication, and Hotwire (Turbo + Stimulus) with Tailwind CSS for the frontend.

## Common Commands

```bash
bin/dev                          # Start all dev processes (Rails server, JS/CSS watch)
bundle exec rspec                # Run full test suite
bundle exec rspec spec/models/habit_spec.rb  # Run a single spec file
bundle exec rubocop              # Lint
bundle exec brakeman             # Security scan
bundle exec bundler-audit        # Gem vulnerability audit
bin/rails db:migrate             # Apply migrations
bin/rails db:seed                # Seed development data (3 users, random habits + entries)
```

## Architecture

**Authentication**: All controllers require `authenticate_user!` via `ApplicationController`. Authentication is SSO-only via OmniAuth — users sign in through the Aronnax OAuth2 provider (`aronnax-core`, port 3050). No registration or password reset — accounts are created automatically on first SSO login. Devise's `:database_authenticatable` is retained only to preserve session route helpers (`new_user_session_path`, etc.) that `Devise::FailureApp` requires; no password is ever set. Authenticated users land on `dashboard#index`; unauthenticated users see `welcome#index`.

**Authorization**: Resources are scoped to the current user. `HabitsController` queries through `current_user.habits`; `HabitEntriesController` scopes entries through `current_user.habits.find(params[:habit_id])`.

**Models**:
- `ApplicationRecord` — UUID defaults, `implicit_order_column = "created_at"`
- `User` — `has_one :profile`, `has_many :habits` (both dependent: :destroy); `after_create :add_profile` auto-creates a Profile using `UniqueNicknameGenerator` and `Current.locale`; `from_omniauth(auth)` finds-or-creates by (provider, uid) then email; `aronnax` returns a valid `OAuth2::AccessToken`, refreshing via `aronnax_refresh_token` if expired (raises `User::TokenExpiredError` if no refresh token available)
- `Profile` — `belongs_to :user`; `language` enum (`en: 0, uk: 1`); `nickname` (unique, required); `self.human_enum_name(enum_name, value)` for display labels
- `Habit` — belongs_to :user; has_many :entries (class_name: "HabitEntry"); `active_on?(date)` helper checks start_date/end_date range
- `HabitEntry` — belongs_to :habit; `date` must be ≤ today (no future entries allowed)
- `Current < ActiveSupport::CurrentAttributes` (`app/models/current.rb`) — holds `:locale` so models can read the request locale without coupling to the controller

**Strong parameters**: Uses `params.expect()` (Rails 8 style), not the older `require/permit` pattern.

**Service objects** (`app/services/`):
- `DashboardWeekBuilder` — builds weekly view data; loads active habits and entries in two queries; returns an array of `WeekDay` structs each containing `HabitWithEntry` pairs.
- `UniqueNicknameGenerator` — generates a unique nickname from a base string by appending an incrementing integer until no conflict exists.

**Layout**: Fixed sidebar on desktop; hidden drawer on mobile (Stimulus `drawer` controller). Sidebar partial at `app/views/layouts/partials/_sidebar.html.erb`; active nav item determined by `controller_name`.

## Data Model

- **User**: id (UUID), email (unique), provider, uid, aronnax_access_token, aronnax_refresh_token, aronnax_expires_at, encrypted_password (unused — retained for Devise route helper compatibility)
- **Profile**: id (UUID), user_id (FK), nickname (required, unique), language (integer enum: en/uk), week_starts_on (integer enum)
- **Habit**: id (UUID), user_id (FK), name (required), description, start_date (required), end_date (optional)
- **HabitEntry**: id (UUID), habit_id (FK), date (required, ≤ today, unique per habit), completed (boolean), note

## Routes

```
GET    /                      → dashboard#index (authenticated), welcome#index (public)
GET    /users/auth/aronnax    → initiates OmniAuth SSO flow
GET    /users/auth/aronnax/callback → OmniauthCallbacksController#aronnax
resource  :profile            → show / edit / update / destroy
PATCH /locale                 → locales#update  (sets cookies[:locale] for guests)
resources :habits             → full CRUD
  resources :habit_entries    → path: "entries" — new/create/edit/update only
                                member: toggle_completion (PATCH)
                                helpers: new_habit_entry_path, habit_entries_path,
                                         edit_habit_entry_path, habit_entry_path
```

The nested habit_entries resource uses `path: "entries", as: :entries` — URLs are `/habits/:habit_id/entries/...`. `form_with` requires an explicit `url:` since polymorphic routing doesn't resolve the custom `as:` alias.

`resource :profile` is singular — `form_with` requires `url: profile_path` explicitly.

## i18n

- **Two locales**: `en` (default) and `uk`; declared via `config.i18n.available_locales` and `config.i18n.default_locale` in `config/application.rb`.
- **Locale files**: `config/locales/en.yml`, `config/locales/uk.yml`, `config/locales/devise.en.yml`, `config/locales/devise.uk.yml`.
- **`rails-i18n` gem** provides Ukrainian day and month names consumed by the `l()` date helper.
- **Lazy lookup**: `t(".key")` in a view resolves relative to the template path; partials strip the leading `_` (e.g. `_habit_row.html.erb` → `en.dashboard.habit_row`).
- **Named date formats** (`dashboard_full`, `dashboard_day`, `dashboard_short`, `dashboard_long`) are defined in each locale file and used as `l(date, format: :dashboard_short)` in dashboard partials.
- **Enum labels** live under `activerecord.attributes.<model>.<enum_plural>.<value>` (e.g. `activerecord.attributes.profile.languages.uk`).
- **Devise form labels** (email, password, etc.) are translated via `activerecord.attributes.user.*` in each locale file.
- **Locale resolution per request** (`ApplicationController#set_locale`, `around_action`):
  - Authenticated → `current_user.profile.language.to_sym`
  - Guest → `cookies[:locale]` (written by `LocalesController#update`)
  - Falls back to `I18n.default_locale` if the resolved value is not in `available_locales`
- `Current.locale` is set to the resolved locale string alongside `I18n.with_locale`, so models (e.g. `User#add_profile`) can read it without access to cookies or the request.

## Testing

RSpec with FactoryBot (FFaker for data), Shoulda Matchers, and Devise request helpers.

Request specs authenticate via the `"authenticated user"` shared context:

```ruby
describe "/habits", type: :request do
  include_context "authenticated user"
  # user and sign_in are set up automatically
end
```

Factories in `spec/factories/`: `:habit` requires explicit `user:`, `:habit_entry` requires explicit `habit:`. The `:habit` factory sets `start_date: Date.current - 1.day` by default.

**Profile specs**: use `subject { create(:user).profile }` — leverages the `after_create :add_profile` callback to get a persisted Profile without a separate factory. A persisted subject is required for `validate_uniqueness_of`.

**UniqueNicknameGenerator specs**: use `create(:user).profile.update!(nickname: "taken")` to seed collision state directly — no profile factory needed.

**Locale-dependent model specs**: set `Current.locale = "uk"` before `create(:user)` to test that the profile inherits the locale as its language. `CurrentAttributes` resets automatically between requests but not between RSpec examples — reset manually if needed (`Current.reset` or set explicitly per example).

## Database

PostgreSQL with `pgcrypto` extension for UUID generation. Schema uses `uuid` primary keys throughout. Run `bin/rails db:schema:load RAILS_ENV=test` if the test DB diverges from schema.rb.
