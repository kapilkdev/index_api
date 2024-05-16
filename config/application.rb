require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module IndexApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.api_only = true
    config.load_defaults 7.0
    config.middleware.use ActionDispatch::Flash
    config.active_job.queue_adapter = :sidekiq
    config.middleware.use ActionDispatch::Flash
    config.session_store :cookie_store, key: '_interslice_session'
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, 
    config.session_options
    config.middleware.use Rack::MethodOverride
    config.active_record.yaml_column_permitted_classes
    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone]
    config.factory_bot.definition_file_paths = ["custom/factories"]
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
