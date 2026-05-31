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
```

## Architecture

**Authentication**: All controllers require `authenticate_user!` via `ApplicationController`. Devise handles sign-up, sign-in, and password reset.

**Authorization**: Resources are scoped to the current user — `HabitsController` always queries through `current_user.habits`, never the global model.

**Models**: `ApplicationRecord` sets UUID defaults and `implicit_order_column = "created_at"`. User has_many :habits (dependent: :destroy); Habit belongs_to :user.

**Strong parameters**: Uses `params.expect()` (Rails 8 style), not the older `require/permit` pattern.

## Testing

RSpec with FactoryBot (FFaker for data), Shoulda Matchers, and Devise request helpers.

Request specs authenticate via the `"authenticated user"` shared context:

```ruby
describe "/habits", type: :request do
  include_context "authenticated user"
  # user and sign_in are set up automatically
end
```

Factories are in `spec/factories/`. The `:habit` factory requires an explicit `user:` association when the test user matters for authorization checks.

## Database

PostgreSQL with `pgcrypto` extension for UUID generation. Schema uses `uuid` primary keys throughout.
