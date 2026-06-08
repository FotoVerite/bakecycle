# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bakecycle
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = "Eastern Time (US & Canada)"
    config.active_record.default_timezone = :local

    config.generators do |g|
      g.factory_bot true
      g.test_framework :rspec
      g.stylesheets false
      g.javascripts false
      g.helper false
      g.decorator false
    end

    ActionMailer::Base.delivery_method = :smtp
  end
end
