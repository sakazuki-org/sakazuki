# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SAKAZUKI is a Japanese sake (日本酒) inventory management application built with Rails. It allows users to track their sake collection, record tasting notes with quantitative/qualitative specs, search inventory, and share with multiple users. Images are compressed to AVIF format and uploaded to Cloudinary.

## Technology Stack

- **Backend**: Rails 8.0.2.1 with Ruby 3.4.5
- **Database**: PostgreSQL >= 12.0
- **Frontend**: Hotwire (Turbo + Stimulus), Bootstrap 5, esbuild for JavaScript bundling, Sass for CSS
- **Authentication**: Devise (with invitable, confirmable, lockable, trackable)
- **Image Upload**: CarrierWave + Cloudinary (AVIF compression)
- **Search**: Ransack for full-text search
- **Pagination**: Kaminari
- **Testing**: RSpec with FactoryBot, Capybara, Selenium WebDriver
- **Code Quality**: RuboCop, ERB Lint, Brakeman, ESLint, Prettier, Stylelint, Markuplint

## Development Commands

### Setup

```bash
# Install dependencies
bundle install
corepack enable && yarn install

# Setup .env file
cp dotenv.example .env
# Edit .env with your PostgreSQL credentials

# Database setup
bundle exec rails db:prepare
bundle exec rake parallel:setup  # For parallel testing

# Create admin user (optional: edit db/seed.rb first)
bundle exec rails db:seed

# Start server
bundle exec rails server
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

- Bottle state tracking: `bottle_level` enum (sealed/opened/empty) with automatic timestamp management via `BottleStateTimestampable` concern
- Sake specifications: `tokutei_meisho` (special designation), `nihonshudo` (sake meter value), `sando` (acidity), `seimai_buai` (rice polishing ratio), `alcohol`, etc.
- Production details: `kura` (brewery), `todofuken` (prefecture), `genryomai`/`kakemai` (rice varieties), `kobo` (yeast), `moto` (starter method), `hiire` (pasteurization)
- Tasting notes: `aroma_value`, `taste_value`, `rating`, `aroma_impression`, `taste_impression`
- Associated with `Photo` model for image uploads
- Full-text search enabled via Ransack with custom `all_text` alias
- Business logic: `alcohol_stock()` calculates total inventory, `new_arrival?` determines if sake is new, `selling_price()` calculates per-go pricing

**User** (`app/models/user.rb`): Authentication via Devise with full features enabled (confirmable, lockable, timeoutable, trackable, invitable). Admin flag for administrative users.

**Photo** (`app/models/photo.rb`): CarrierWave uploader for sake images, uploads to Cloudinary with AVIF compression.

### Controllers

**SakesController** (`app/controllers/sakes_controller.rb`): Main CRUD controller with Ransack search integration. Custom `menu` collection route for additional UI.

**Authentication**: Devise controllers customized in `app/controllers/users/` for registrations and invitations.

### Frontend Architecture

**JavaScript**: Uses Hotwire (Turbo Rails + Stimulus) for SPA-like experience without heavy JavaScript frameworks. Entry point at `app/javascript/application.js`, bundled with esbuild.

**Stimulus Controllers**: Located in `app/javascript/controllers/` for interactive components.

**Custom JavaScript Modules**:

- `taste_graph/`: Taste profile visualization (likely Chart.js)
- `completion/`: Auto-completion functionality
- `simple_lightbox/`: Image lightbox gallery

**CSS**: Bootstrap 5 + custom SCSS in `app/assets/stylesheets/`, compiled via Sass.

### Localization

Application is primarily Japanese (`config.i18n.default_locale = :ja`) with timezone set to Tokyo. Locale files in `config/locales/**/*.ja.{rb,yml}`. Uses `enum_help` and `rails-i18n` for Japanese enum/model translations.

### Testing Strategy

**RSpec** with type inference by file location. Helpers:

- Devise integration helpers for request/system specs
- FactoryBot for test data (factories in `spec/factories/`)
- Capybara + Selenium for system tests
- SimpleCov for coverage (outputs to `coverage/`, Cobertura format for CI)
- Custom `SignIn` helper included for system specs
- ActiveSupport::Testing::TimeHelpers for time-dependent tests

### Email Development

In development, emails viewable at `http://localhost:3000/letter_opener` via `letter_opener_web` gem.

## Important Patterns

### Concerns

Model concerns in `app/models/concerns/`:

- `BottleStateTimestampable`: Automatically manages `opened_at` and `emptied_at` based on `bottle_level` changes

### Ransack Security

Models explicitly whitelist searchable attributes/associations via `ransackable_attributes` and `ransackable_associations` methods to prevent security issues.

### Bootstrap Error Styling

Custom `field_error_proc` in `config/application.rb` adds Bootstrap's `is-invalid` class to form fields with validation errors.

### Enums with Prefix

All model enums use `:prefix` option to avoid method name conflicts (e.g., `hiire_namanama` instead of just `namanama`).

## Development Notes

- Node.js version tracked in `.node-version` (>= 22 required)
- Ruby version in `.ruby-version` (3.4.5)
- Uses Yarn 4.7.0 (configured in `packageManager` field, enable with `corepack enable`)
- libvips required for development (image processing)
- Parallel test databases setup via `parallel:setup` task
- Extensive validation on Sake model - be careful when modifying attributes
- Google AdSense integration available (configure in .env)

## Deployment

See [deployment wiki](https://github.com/momocus/sakazuki/wiki/Deployment) for production deployment instructions. Application can be deployed to Fly.io (see `fly.toml`).

## Instructions

Always use Japanese.
