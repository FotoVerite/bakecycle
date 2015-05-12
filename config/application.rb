require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bakecycle
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # new 4.2+ behavior
    config.active_record.raise_in_transactional_callbacks = true

    config.serve_static_files = true

    # for bower stuff
    config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')

    # for foundation
    config.assets.precompile += %w( vendor/modernizr.js )

    # fonts
    config.assets.precompile << /(?:eot|svg|ttf|woff)$/

    config.generators do |g|
      g.factory_girl true
      g.test_framework :rspec
    end

    ActionMailer::Base.smtp_settings = {
      address: 'smtp.sendgrid.net',
      port: '587',
      authentication: :plain,
      user_name: ENV['SENDGRID_USERNAME'],
      password: ENV['SENDGRID_PASSWORD'],
      domain: 'bakecycle.com',
      enable_starttls_auto: true
    }

    ActionMailer::Base.delivery_method = :smtp
  end
end
