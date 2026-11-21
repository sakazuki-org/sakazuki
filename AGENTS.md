# Repository Guidelines

## Project Structure & Module Organization

SAKAZUKI is a Rails app backed by PostgreSQL. Core controllers, mailers, and models live in `app/`, while TypeScript entrypoints and Stimulus controllers sit under `app/javascript/` and compile to `app/assets/builds/`. Database migrations and seeds are in `db/`, and RSpec suites with factories land in `spec/` and `spec/factories/`. Shared utilities live in `lib/`, and automation scripts reside in `cli-scripts/`. Copy `dotenv.example` to `.env` for local secrets.

## Build, Test, and Development Commands

- `bundle exec rails db:prepare` creates and migrates development and test databases.
- `bin/dev` (or `foreman start -f Procfile.dev`) boots the Rails server and asset watcher on `http://localhost:3000`.
- `yarn build` bundles JavaScript via esbuild; add `yarn build:css` after SCSS updates.
- `yarn lint` calls `cli-scripts/run-all-checks.sh` covering JS/TS linters, formatters, RuboCop, ERB Lint, Brakeman, Hadolint, and GitHub workflow checks.

## Coding Style & Naming Conventions

Respect `.editorconfig`: two-space indentation, LF endings, UTF-8 encoding, and four-space shell scripts. RuboCop enforces double-quoted Ruby strings, semantic block delimiters (procedural `do...end`, functional `{}`), and explicit parentheses for method calls with arguments. Rails files should keep conventional names (`*_controller.rb`, `*_job.rb`, `*_component.rb`). Front-end code uses TypeScript modules with camelCase functions and PascalCase classes; Prettier is configured for no semicolons. SCSS in `app/assets/stylesheets/` should namespace components to avoid clashing with Bootstrap.

## Testing Guidelines

Run `bundle exec rspec` for the full suite; switch to `bundle exec rake parallel:spec` on CI-sized changes. Keep specs beside the feature they exercise—system specs under `spec/system`, request specs under `spec/requests`, and shared helpers in `spec/support`. SimpleCov boots in `spec/rails_helper.rb`, so keep coverage noise low and prune dead code. Update factories and seeds alongside database or service changes to keep `db:prepare` fast.

## Commit & Pull Request Guidelines

Commit messages follow a Conventional-Commit-inspired style: `Type(scope): summary` (e.g., `Fix(auth): handle expired sessions`) with dependency bumps prefixed `Build(deps): ...`. Keep commits focused, include screenshots for UI changes, and mention any schema or background job updates. Pull requests should state the motivation, link issues, and call out env or data changes. Verify `yarn lint`, `bundle exec rspec`, and `bundle exec rails db:prepare` before requesting review, and note any skipped checks.

## Environment & Security Notes

Secrets stay outside version control; fill `.env` with Cloudinary, PostgreSQL, and AdSense credentials per `dotenv.example`. Update `fly.toml`, `compose.yaml`, and `.github/` workflows together on deployment changes. Run the lint bundle early and often to spot newline, dependency, or configuration drift before commit.

## Instruction

Always use Japanese.
