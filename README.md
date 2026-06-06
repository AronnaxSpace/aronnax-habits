# Aronnax Habits

A personal habit-tracking web app. Create habits, mark daily entries, and review
your progress in a weekly dashboard. Built with Rails 8 and Hotwire, with full
English and Ukrainian localization.

## Tech Stack

- **Ruby** 4.0.5 / **Rails** 8.1.3
- **PostgreSQL** (UUID primary keys, `pgcrypto` extension)
- **Devise** for authentication
- **Hotwire** (Turbo + Stimulus) for the frontend
- **Tailwind CSS** 4 (compiled via the standalone CLI)
- **esbuild** for JavaScript bundling
- **RSpec** + FactoryBot + Shoulda Matchers for testing

## Features

- Email/password authentication (sign-up, sign-in, password reset) via Devise
- Per-user habits with start/end dates and daily completion entries
- Weekly dashboard view of active habits and their entries
- User profiles with a unique auto-generated nickname
- Internationalization: English (default) and Ukrainian, resolved per request
  from the user's profile (or a cookie for guests)

## Getting Started

### Prerequisites

- Ruby 4.0.5 (see `.ruby-version`)
- Node 24.15.0 (see `.node-version`) and Yarn
- PostgreSQL

### Setup

```bash
bundle install
yarn install
bin/rails db:prepare      # create, load schema, and seed
```

`db:prepare` seeds development data (3 users with random habits and entries).
To seed manually, run `bin/rails db:seed`.

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
bundle exec rubocop          # lint (rubocop-rails-omakase)
bundle exec brakeman         # static security analysis
bundle exec bundler-audit    # gem vulnerability audit
```

These checks also run in CI (`.github/workflows/ci.yml`).

## Architecture

A high-level overview of the data model, services, routing, and i18n setup lives
in [CLAUDE.md](CLAUDE.md).

- **Models**: `User` → `Profile` (one) and `Habit` (many); `Habit` → `HabitEntry`
  (many). `Current` (an `ActiveSupport::CurrentAttributes`) holds the request
  locale so models can read it without touching the controller.
- **Services** (`app/services/`): `DashboardWeekBuilder` assembles the weekly
  dashboard data; `UniqueNicknameGenerator` produces collision-free nicknames.
- **Authorization**: all resources are scoped through `current_user`.

## Deployment

A `Dockerfile` and a Capistrano `Capfile` are included for containerized and
SSH-based deployment respectively.
