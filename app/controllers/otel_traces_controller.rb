# frozen_string_literal: true

# Relays browser-generated OTLP trace spans (see app/assets/javascripts/otel_web.js)
# to Honeycomb, reusing the OTEL_EXPORTER_OTLP_* env vars the backend's own
# OpenTelemetry SDK already reads (config/initializers/opentelemetry.rb). This
# keeps the Honeycomb API key server-side only and avoids CORS entirely, since
# the browser only ever talks to this same-origin endpoint.
#
# Deliberately not an ApplicationController subclass: no Devise session, no
# Pundit policy, and no CSRF token exist for a page-unload beacon, and none of
# those concerns apply to a telemetry sink.
class OtelTracesController < ActionController::Base
  # No session/user state exists for a page-unload beacon to forge, and
  # config.action_controller.default_protect_from_forgery (Rails 5.2+ default,
  # config/application.rb:14) turns CSRF checking on for every ActionController::Base
  # subclass -- so this has to be opted out explicitly, not just left uncalled.
  skip_forgery_protection

  MAX_BODY_BYTES = 256 * 1024

  def create
    return head :not_found unless endpoint

    body = request.body.read(MAX_BODY_BYTES + 1)
    return head :payload_too_large if body.nil? || body.bytesize > MAX_BODY_BYTES

    response = forward(body)
    head response.code.to_i
  rescue StandardError => e
    Rails.logger.warn("[otel_traces] failed to forward frontend spans: #{e.class}: #{e.message}")
    head :bad_gateway
  end

  private

  def forward(body)
    uri = URI.parse(endpoint)
    request_out = build_request(uri, body)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 2, read_timeout: 5) do |http|
      http.request(request_out)
    end
  end

  def build_request(uri, body)
    request_out = Net::HTTP::Post.new(uri)
    request_out["Content-Type"] = request.content_type.presence || "application/json"
    otlp_headers.each { |key, value| request_out[key] = value }
    request_out.body = body
    request_out
  end

  def endpoint
    ENV["OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"].presence ||
      ENV["OTEL_EXPORTER_OTLP_ENDPOINT"].presence&.then { |root| "#{root.chomp('/')}/v1/traces" }
  end

  def otlp_headers
    ENV["OTEL_EXPORTER_OTLP_HEADERS"].to_s.split(",").each_with_object({}) do |pair, memo|
      key, value = pair.split("=", 2)
      memo[key.strip] = value.strip if key && value
    end
  end
end
