# frozen_string_literal: true

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

  # Error tracking only -- no performance tracing/spans. traces_sample_rate
  # defaults to 0.0 (disabled) when unset; leave it unset rather than 0.0
  # explicitly so it's clear this is a deliberate choice, not an oversight.
end
