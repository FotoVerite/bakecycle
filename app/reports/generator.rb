# frozen_string_literal: true

module Generator
  TRACER = defined?(OpenTelemetry) ? OpenTelemetry.tracer_provider.tracer("bakecycle-reports") : nil

  def self.included(base)
    base.include GlobalID::Identification
    base.prepend Instrumentation
  end

  def content_type
    case File.extname(filename)
    when ".pdf"  then "application/pdf"
    when ".xlsx" then "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    when ".csv"  then "text/csv"
    when ".iif"  then "text/plain"
    else "application/octet-stream"
    end
  end

  # One attribute-tagged span per report generated -- which report type ran,
  # how long it took. That's the whole point: usage visibility ("what reports
  # do people actually run"), not a blow-by-blow of internal steps.
  module Instrumentation
    def generate
      return super unless Generator::TRACER

      Generator::TRACER.in_span(
        "report.generate",
        attributes: { "report.type" => self.class.name.delete_suffix("Generator").underscore }
      ) { super }
    end
  end
end
