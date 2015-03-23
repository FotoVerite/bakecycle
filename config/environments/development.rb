Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.serve_static_assets = true

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = true

  config.active_support.deprecation = :raise

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  config.action_controller.action_on_unpermitted_parameters = :raise

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.action_controller.action_on_unpermitted_parameters = :raise

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }
end
