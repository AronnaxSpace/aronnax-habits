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

**Authentication**: All controllers require `authenticate_user!` via `ApplicationController`. Devise handles sign-up, sign-in, and password reset. Authenticated users land on `dashboard#index`; unauthenticated users see `welcome#index`.

**Authorization**: Resources are scoped to the current user. `HabitsController` queries through `current_user.habits`; `HabitEntriesController` scopes entries through `current_user.habits.find(params[:habit_id])`.

**Models**:
- `ApplicationRecord` — UUID defaults, `implicit_order_column = "created_at"`
- `User` — has_many :habits (dependent: :destroy)
- `Habit` — belongs_to :user; has_many :entries (class_name: "HabitEntry"); `active_on?(date)` helper checks start_date/end_date range
- `HabitEntry` — belongs_to :habit; `date` must be ≤ today (no future entries allowed)

**Strong parameters**: Uses `params.expect()` (Rails 8 style), not the older `require/permit` pattern.

**Service object**: `DashboardWeekBuilder` (`app/services/`) builds the weekly view data — loads active habits and existing entries for a week in two queries, returns an array of `WeekDay` structs each containing `HabitWithEntry` pairs.

**Layout**: Fixed sidebar on desktop; hidden drawer on mobile (Stimulus `drawer` controller in `app/javascript/controllers/drawer_controller.js`).

## Data Model

- **Habit**: id (UUID), user_id (FK), name (required), description, start_date (required), end_date (optional)
- **HabitEntry**: id (UUID), habit_id (FK), date (required, ≤ today, unique per habit), completed (boolean), note

## Routes

```
GET  /                        → dashboard#index (authenticated), welcome#index (public)
resources :habits             → full CRUD
  resources :habit_entries    → path: "entries" — new/create/edit/update only
                                helpers: new_habit_entry_path, habit_entries_path,
                                         edit_habit_entry_path, habit_entry_path
```

The nested habit_entries resource uses `path: "entries", as: :entries` — URLs are `/habits/:habit_id/entries/...`. `form_with` requires an explicit `url:` since polymorphic routing doesn't resolve the custom `as:` alias.

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

## Database

PostgreSQL with `pgcrypto` extension for UUID generation. Schema uses `uuid` primary keys throughout. Run `bin/rails db:schema:load RAILS_ENV=test` if the test DB diverges from schema.rb.
