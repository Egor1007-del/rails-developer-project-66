require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsDeveloperProject66
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])
    config.i18n.available_locales = %i[en ru]
    config.i18n.default_locale = :ru
    config.i18n.fallbacks = [ :en ]
  end
end
