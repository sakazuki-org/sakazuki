require_relative "boot"

# rubocop:disable Style/RequireOrder
require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"
# rubocop:enable Style/RequireOrder

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sakazuki
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults(8.1)

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Rails error forms using Bootstrap is-invalid style
    config.action_view.field_error_proc =
      lambda { |html_tag, _instance|
        doc = Nokogiri::HTML::DocumentFragment.parse(html_tag)
        element = doc.children.first
        form_fields = %w[textarea input select]
        return html_tag unless form_fields.include?(element.name)

        element[:class] = "#{element[:class]} is-invalid"
        ActiveSupport::SafeBuffer.new(doc.to_html)
      }

    # For Japanese
    config.i18n.load_path += Rails.root.glob("config/locales/**/*.ja.{rb,yml}")
    config.i18n.available_locales = %i[en ja]
    config.i18n.default_locale = :ja

    # Timezone
    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local

    # RSpec
    config.generators do |g|
      g.test_framework(:rspec)
    end
  end
end
