Rails.application.configure do
  config.action_mailer.default_url_options = { host: "localhost:3000" }
  config.enable_reloading = true
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Propshaft: don't scan 629 asset files on every request.
  # dartsass:watch handles recompilation; restart server to pick up new files.
  config.assets.sweep_cache = false
  config.assets.quiet = true

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = :all

  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  config.log_level = :debug

  config.action_controller.action_on_unpermitted_parameters = :raise

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.action_controller.action_on_unpermitted_parameters = :raise

  config.action_mailer.delivery_method = :letter_opener

  # Mailcatcher config
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }
end
