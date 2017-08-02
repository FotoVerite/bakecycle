Rails.application.configure do
  config.action_mailer.default_url_options = { host: "localhost:3000" }
  config.cache_classes = true
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.static_cache_control = "public, max-age=3600"

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # I want this to be raise
  config.active_support.deprecation = :log

  config.action_controller.action_on_unpermitted_parameters = :raise

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # rails has started complaining
  config.assets.precompile += %w(test/stripe.js)
end
