source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "8.0.4"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

# Use PostgeSQL as the database for Active Record
gem "pg"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# For Japanese
gem "enum_help"
gem "rails-i18n"

# For authentication
gem "bcrypt"
gem "devise"
gem "devise-i18n"
gem "devise_invitable"

# Create seed data files from the existing data in database
gem "seed_dump"

# For image uploading
gem "carrierwave"
gem "carrierwave-i18n"
gem "cloudinary"

# For twitter card
gem "meta-tags"

# For complex search
gem "ransack"

# Pagination
gem "kaminari"
gem "kaminari-i18n"

# Japanese Era
gem "era_ja"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug"

  # Use .env file
  gem "dotenv-rails"

  # Mailer
  gem "letter_opener_web"
end

group :development do
  # Auto annotation to schema
  gem "annotaterb"

  # Generate dockerfile for fly deploy
  gem "dockerfile-rails"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Rubocop
  gem "rubocop", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-erb", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false

  # Useful debugger in browser
  gem "better_errors"
  gem "binding_of_caller"

  # Lint ERB files
  gem "erb_lint", require: false

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Documentation
  gem "yard"
end

group :test do
  # FactoryBot for RSpec
  gem "factory_bot_rails"

  # parallel test
  gem "parallel_tests"

  # RSpec
  gem "rspec-rails"

  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"

  # Selenium used by Capybara
  gem "selenium-webdriver"

  # Simple coverage
  gem "simplecov"
  gem "simplecov-cobertura" # For CodeCov integration
end
