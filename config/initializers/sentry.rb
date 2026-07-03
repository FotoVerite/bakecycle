return unless defined?(Sentry)

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"].presence || Rails.application.credentials.dig(:sentry, :dsn)

  config.environment = Rails.env
  config.enabled_environments = %w[production staging]

  config.breadcrumbs_logger = %i[
    active_support_logger
    http_logger
  ]

  config.send_default_pii = false

  config.traces_sample_rate = 1.0
end
