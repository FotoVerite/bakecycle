# frozen_string_literal: true

return unless defined?(OpenTelemetry)

# Deliberately minimal, hand-picked instrumentation -- not
# opentelemetry-instrumentation-all. Rack + ActionPack only, giving one span
# per HTTP request tagged with route/controller/action/status/duration. That
# alone answers "what parts of the app are people actually using" without
# auto-instrumenting every DB query/gem call (the firehose Sentry's default
# APM produced, which this deliberately replaces).
OpenTelemetry::SDK.configure do |c|
  c.service_name = "bakecycle-#{Rails.env}"
  c.use "OpenTelemetry::Instrumentation::Rack"
  c.use "OpenTelemetry::Instrumentation::ActionPack"
end
