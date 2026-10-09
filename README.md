# Aronnax Habits

A personal habit-tracking web app. Create habits, mark daily entries, and review
your progress in a weekly dashboard. Built with Rails 8 and Hotwire, with full
English and Ukrainian localization.

## Tech Stack

- **Ruby** 4.0.7 / **Rails** 8.1
- **PostgreSQL** (UUID primary keys, `pgcrypto` extension)
- **Devise** + **OmniAuth** — sign-in is SSO-only through the Aronnax identity provider
  ([aronnax-core](https://github.com/AronnaxSpace/aronnax-core))
- **Hotwire** (Turbo + Stimulus) for the frontend
- **Tailwind CSS** 4 (via `cssbundling-rails`, using `@tailwindcss/cli`)
- **esbuild** for JavaScript bundling (via `jsbundling-rails`)
- **RSpec** + FactoryBot + Shoulda Matchers for testing

## Features

- Sign in with your Aronnax account (SSO only — no local passwords, sign-up or password reset; an
  account is created automatically on first sign-in)
- Per-user habits with start/end dates, a frequency (daily, weekly, twice or thrice a week) and daily
  completion entries
- Weekly dashboard view of active habits and their entries
- User profiles with a unique auto-generated nickname
- Internationalization: English (default) and Ukrainian, resolved per request
  from the user's profile (or a cookie for guests)

## Getting Started

### Prerequisites

- Ruby 4.0.7 (see `.ruby-version`)
- Node 24.21.0 (see `.node-version`) and Yarn
- PostgreSQL (no Redis needed — this app has no background worker)
- The per-environment credentials key (`config/credentials/<env>.key`, gitignored)
- A running Aronnax SSO provider for sign-in to work in development — this app has no local password
  fallback. Run `aronnax-core` on `http://localhost:3050` and register this app there as an OAuth
  application with redirect URI `http://localhost:3052/users/auth/aronnax/callback`; the matching
  `app_id` / `app_secret` / `site` go under `aronnax:` in the development credentials. See
  [aronnax-dev](https://github.com/AronnaxSpace/aronnax-dev) `docs/DEVELOPMENT.md`.

### Setup

```bash
bin/setup                 # bundle + yarn + db:prepare + start server
                          # use --skip-server to skip starting the server, --reset to reset the DB
```

`db:prepare` seeds development data (`user_1..3@aronnax.space` with random habits and entries). Seeded
users have no SSO identity yet; signing in through core with the same email links to them. To seed
manually, run `bin/rails db:seed`.

### Running the app

```bash
bin/dev
```

This starts the Rails server plus the JS and CSS watchers (see `Procfile.dev`).
The app is then available at http://localhost:3052.

## Testing

```bash
bundle exec rspec                            # full suite
bundle exec rspec spec/models/habit_spec.rb  # a single file
```

If the test database diverges from `schema.rb`:

```bash
bin/rails db:schema:load RAILS_ENV=test
```

## Code Quality

```bash
bin/rubocop          # lint (rubocop-rails-omakase)
bin/brakeman         # static security analysis
bin/bundler-audit    # gem vulnerability audit
bin/ci               # all of the above plus setup and yarn audit
```

Brakeman, bundler-audit and RuboCop also run in GitHub Actions (`.github/workflows/ci.yml`); RSpec does
**not**, so run it locally before pushing.

## Architecture

A high-level overview of the data model, services, routing, and i18n setup lives
in [CLAUDE.md](CLAUDE.md).

- **Models**: `User` → `Profile` (one) and `Habit` (many); `Habit` → `HabitEntry`
  (many). `Current` (an `ActiveSupport::CurrentAttributes`) holds the request
  locale so models can read it without touching the controller.
- **Services** (`app/services/`): `DashboardWeekBuilder` assembles the weekly
  dashboard data; `UniqueNicknameGenerator` produces collision-free nicknames.
- **Authentication**: SSO-only via a custom OmniAuth OAuth2 strategy
  (`lib/omniauth/strategies/aronnax.rb`); this app is an OAuth client of `aronnax-core`.
- **Authorization**: all resources are scoped through `current_user`.

## Deployment

Deployed with Capistrano (`bin/cap production deploy`) to the shared VPS (Passenger + rbenv). A
`Dockerfile` is also included.
