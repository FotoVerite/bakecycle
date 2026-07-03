# frozen_string_literal: true

module Generator
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

  def sentry_report_attributes
    {
      bakery_id: sentry_report_value(:@bakery)&.id,
      date: sentry_report_date(:@date),
      bake_date: sentry_report_date(:@bake_date),
      start_date: sentry_report_date(:@start_date),
      end_date: sentry_report_date(:@end_date),
      date_count: sentry_report_date_count,
      type: sentry_report_value(:@type),
      source: sentry_report_value(:@source),
      year: sentry_report_value(:@year),
      print_invoices: sentry_report_value(:@print_invoices),
      order_id: sentry_report_value(:@order)&.id,
      shipment_id: sentry_report_value(:@shipment)&.id || sentry_report_value(:@invoice)&.id,
      production_run_id: sentry_report_value(:@production_run)&.id,
      search_id: sentry_report_value(:@search)&.id,
      order_item_count: sentry_report_value(:@order_items)&.size
    }
  end

  module Instrumentation
    def generate
      return super unless defined?(Sentry) && Sentry.respond_to?(:with_child_span)

      started_at = Time.current
      output = nil

      Sentry.with_child_span(op: "report.generate", description: sentry_report_name) do |span|
        set_sentry_report_data(span, started_at: started_at) if span
        output = super()
        set_sentry_report_result_data(span, output: output, started_at: started_at) if span
      end

      output
    end

    private

    def sentry_report_name
      self.class.name.delete_suffix("Generator").underscore.humanize
    end

    def set_sentry_report_data(span, started_at:)
      sentry_base_report_attributes(started_at).merge(sentry_report_attributes).each do |key, value|
        span.set_data(key.to_s, value) if value.present?
      end
    end

    def set_sentry_report_result_data(span, output:, started_at:)
      span.set_data("duration_ms", ((Time.current - started_at) * 1000).round(1))
      span.set_data("output_bytes", output.bytesize) if output.respond_to?(:bytesize)
    end

    def sentry_base_report_attributes(started_at)
      {
        generator: self.class.name,
        generator_id: respond_to?(:id) ? id : nil,
        filename: respond_to?(:filename) ? filename : nil,
        content_type: respond_to?(:content_type) ? content_type : nil,
        generated_at: started_at.iso8601
      }
    end
  end

  private

  def sentry_report_value(name)
    instance_variable_get(name) if instance_variable_defined?(name)
  end

  def sentry_report_date(name)
    value = sentry_report_value(name)
    value.respond_to?(:iso8601) ? value.iso8601 : value
  end

  def sentry_report_date_count
    start_date = sentry_report_value(:@start_date) || sentry_report_value(:@date) || sentry_report_value(:@bake_date)
    end_date = sentry_report_value(:@end_date) || start_date
    return unless start_date.respond_to?(:to_date) && end_date.respond_to?(:to_date)

    (start_date.to_date..end_date.to_date).count
  end
end
