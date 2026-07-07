# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OTel trace relay", type: :request do
  it "404s when no OTEL endpoint is configured" do
    post "/otel/v1/traces", params: "{}", headers: { "Content-Type" => "application/json" }
    expect(response.status).to eq(404)
  end

  it "forwards to the configured endpoint without CSRF" do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("OTEL_EXPORTER_OTLP_ENDPOINT").and_return("https://api.honeycomb.io")
    allow(ENV).to receive(:[]).with("OTEL_EXPORTER_OTLP_TRACES_ENDPOINT").and_return(nil)
    allow(ENV).to receive(:[]).with("OTEL_EXPORTER_OTLP_HEADERS").and_return("x-honeycomb-team=abc123")

    stub_request(:post, "https://api.honeycomb.io/v1/traces")
      .with(headers: { "x-honeycomb-team" => "abc123" })
      .to_return(status: 202, body: "")

    post "/otel/v1/traces", params: "{}", headers: { "Content-Type" => "application/json" }
    expect(response.status).to eq(202)
  end
end
