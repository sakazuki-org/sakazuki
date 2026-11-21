# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SAKAZUKI is a Japanese sake (日本酒) inventory management application built with Rails. It allows users to track their sake collection, record tasting notes with quantitative/qualitative specs, search inventory, and share with multiple users. Images are compressed to AVIF format and uploaded to Cloudinary.

## Technology Stack

- **Backend**: Rails 8.1 with Ruby 4.0 (exact versions in `Gemfile.lock` and `.ruby-version`)
- **Database**: PostgreSQL >= 18
- **Frontend**: Hotwire (Turbo + Stimulus), Bootstrap 5, TypeScript bundled by esbuild (jsbundling-rails), Sass (cssbundling-rails), served by Propshaft from `app/assets/builds/`
- **Authentication**: Devise (with invitable, confirmable, lockable, trackable)
- **Image Upload**: CarrierWave + Cloudinary (AVIF compression)
- **Search**: Ransack for full-text search
- **Pagination**: Kaminari
- **Testing**: RSpec with FactoryBot, Capybara, Playwright (capybara-playwright-driver)
- **Code Quality**: RuboCop, ERB Lint, Brakeman, ESLint, Prettier, Stylelint, Markuplint

## Development Commands

### Setup

```bash
# Install dependencies
bundle install
corepack enable && yarn install
yarn run playwright install chromium  # For system specs tagged js: true

# Setup .env file
cp dotenv.example .env
# Edit .env with your PostgreSQL credentials

# Database setup
bundle exec rails db:prepare
bundle exec rake parallel:setup  # For parallel testing

# Create admin user (optional: edit db/seed.rb first)
bundle exec rails db:seed

# Start server with JS/CSS watchers (Procfile.dev)
bin/dev
# Or server only (assets are not rebuilt): bundle exec rails server
# Access at http://localhost:3000/
# Default login: example@example.com / rootroot
```

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/sake_spec.rb

# Run specific test by line number
bundle exec rspec spec/models/sake_spec.rb:42

# Run parallel tests
bundle exec rake parallel:spec

# With coverage (outputs to coverage/)
bundle exec rspec
```

### Linting and Code Quality

```bash
# Run all checks (comprehensive CI-like checks)
yarn run lint
# Or: ./cli-scripts/run-all-checks.sh

# Individual linters:
yarn run lint:eslint          # JavaScript
yarn run lint:eslint:fix      # Auto-fix JavaScript
yarn run lint:tsc             # TypeScript type checking
yarn run lint:prettier        # Formatting check
yarn run lint:prettier:fix    # Auto-fix formatting
yarn run lint:markdownlint    # Markdown
yarn run lint:stylelint       # CSS/SCSS
yarn run lint:stylelint:fix   # Auto-fix CSS/SCSS
yarn run lint:markuplint      # HTML/ERB markup

bundle exec rubocop                              # Ruby
bundle exec rubocop -a                           # Auto-fix Ruby
bundle exec rubocop --config .rubocop-erb.yml    # ERB
bundle exec erb_lint --lint-all                  # ERB lint
bundle exec brakeman --no-pager --run-all-checks # Security
```

### Building Assets

```bash
# Build JavaScript
yarn run build

# Build CSS
yarn run build:css

# Generate build metafile for analysis
yarn run build:metafile
```

### Docker Development

```bash
# Build image
docker compose build --build-arg RUBY_VERSION=$(cat .ruby-version)

# Setup database
docker compose run --rm web bundle exec rails db:prepare
docker compose run --rm web bundle exec rake parallel:setup
docker compose run --rm web bundle exec rails db:seed

# Start containers
docker compose up

# Run tests in container
docker compose exec web bundle exec rspec
```

## Code Architecture

### Core Models

**Sake** (`app/models/sake.rb`): Central model representing a Japanese sake bottle. Contains extensive sake-specific attributes:

- Bottle state tracking: `bottle_level` enum (sealed/opened/empty); `opened_at`/`emptied_at` are set by the `BottleStateTimestampable` concern (not automatic, see Concerns below)
- Sake specifications: `tokutei_meisho` (special designation), `nihonshudo` (sake meter value), `sando` (acidity), `seimai_buai` (rice polishing ratio), `alcohol`, etc.
- Production details: `kura` (brewery), `todofuken` (prefecture), `genryomai`/`kakemai` (rice varieties), `kobo` (yeast), `moto` (starter method), `hiire` (pasteurization)
- Tasting notes: `aroma_value`, `taste_value`, `rating`, `aroma_impression`, `taste_impression`
- Associated with `Photo` model for image uploads
- Full-text search enabled via Ransack with custom `all_text` alias
- Business logic: `alcohol_stock()` calculates total inventory, `new_arrival?` determines if sake is new, `selling_price()` calculates per-go pricing

**User** (`app/models/user.rb`): Authentication via Devise with full features enabled (confirmable, lockable, timeoutable, trackable, invitable). Admin flag for administrative users.

**Photo** (`app/models/photo.rb`): Mounts `ImageUploader` (`app/uploaders/`). Cloudinary (AVIF conversion) is used only when `config.x.cloudinary_enabled` is true (production); development and test store files locally. Views pass `Photo#cl_reference` to `cl_image_path` so the same code works in both modes.

### Controllers

**SakesController** (`app/controllers/sakes_controller.rb`): Main CRUD controller. Index search lives in the `SakesSearch` concern and photo add/delete in `SakesPhotos` (`app/controllers/concerns/`). Photos are saved separately after the Sake record (`sake_params.except(:photos)`). Custom `menu` collection route for additional UI.

**Authentication**: Devise controllers customized in `app/controllers/users/` for registrations, invitations, and confirmations. The resend routes for confirmation and unlock emails are deliberately disabled in `config/routes.rb`.

### Frontend Architecture

**JavaScript**: Uses Hotwire (Turbo Rails + Stimulus) for SPA-like experience without heavy JavaScript frameworks. `yarn run build` bundles each file directly under `app/javascript/` as a separate entry (main one: `application.js`). Controllers and modules are TypeScript, type-checked by `yarn run lint:tsc`.

**Stimulus Controllers**: Located in `app/javascript/controllers/` for interactive components.

**Custom JavaScript Modules**:

- `taste_graph/`: Taste profile visualization (Chart.js)
- `completion/`: Auto-completion functionality
- `simple_lightbox/`: Image lightbox gallery

**CSS**: Bootstrap 5 + custom SCSS in `app/assets/stylesheets/`, compiled via Sass.

### Localization

Application is primarily Japanese (`config.i18n.default_locale = :ja`) with timezone set to Tokyo. Locale files in `config/locales/**/*.ja.{rb,yml}`. Uses `enum_help` and `rails-i18n` for Japanese enum/model translations.

### Testing Strategy

**RSpec** with type inference by file location. Helpers:

- Devise integration helpers for request/system specs
- FactoryBot for test data (factories in `spec/factories/`)
- Capybara for system tests: `rack_test` by default, headless Chromium via Playwright when tagged `js: true`
- `spec/support/capybara.rb` adds `find(:test_id, ...)` for `data-testid`, `wait_for_page`, and `wait_for_alert` to avoid flaky JS tests
- SimpleCov for coverage (outputs to `coverage/`, Cobertura format for CI)
- Custom `SignIn` helper included for system specs
- ActiveSupport::Testing::TimeHelpers for time-dependent tests

### Email Development

In development, emails viewable at `http://localhost:3000/letter_opener` via `letter_opener_web` gem.

## Important Patterns

### Concerns

Model concerns in `app/models/concerns/`:

- `BottleStateTimestampable`: Sets `opened_at` and `emptied_at` from `bottle_level` changes. It has no callbacks: `initialize_bottle_state_timestamps` (after create) and `update_bottle_state_timestamps` (after update) must be called explicitly, as `SakesController` does, and each runs `save!` again

### Ransack Security

Models explicitly whitelist searchable attributes/associations via `ransackable_attributes` and `ransackable_associations` methods to prevent security issues.

### Bootstrap Error Styling

Custom `field_error_proc` in `config/application.rb` adds Bootstrap's `is-invalid` class to form fields with validation errors.

### Enums with Prefix

Model enums use `:prefix` option to avoid method name conflicts (e.g., `hiire_namanama` instead of just `namanama`). The exception is `bottle_level`, whose predicates are unprefixed (`sealed?`, `opened?`, `empty?`).

## Development Notes

- Node.js version tracked in `.node-version` (>= 22 required)
- Ruby version in `.ruby-version`
- Uses Yarn 4.7.0 (configured in `packageManager` field, enable with `corepack enable`)
- libvips required for development (image processing)
- Parallel test databases setup via `parallel:setup` task
- Extensive validation on Sake model - be careful when modifying attributes
- Google AdSense integration available (configure in .env)
- Commit messages: `Type: summary` or `Type(scope): summary`, with types such as `Add`, `Update`, `Fix`, and `Build(deps)`

## Deployment

See [deployment wiki](https://github.com/momocus/sakazuki/wiki/Deployment) for production deployment instructions. Application can be deployed to Fly.io (see `fly.toml`).

## Instructions

Always use Japanese.
