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
      return super unless sentry_tracing_available?

      started_at = Time.current
      output = nil

      transaction = current_sentry_transaction
      if sentry_exporter_job_transaction?(transaction)
        set_sentry_report_transaction_data(transaction, started_at: started_at)
        output = super()
        set_sentry_report_result_data(transaction, output: output, started_at: started_at)
        capture_sentry_report_generated(output: output, started_at: started_at)
        return output
      end

      return generate_with_standalone_sentry_transaction(started_at) { super() } unless current_sentry_span

      Sentry.with_child_span(op: "report.generate", description: sentry_report_name) do |span|
        set_sentry_report_data(span, started_at: started_at) if span
        output = super()
        set_sentry_report_result_data(span, output: output, started_at: started_at) if span
        capture_sentry_report_generated(output: output, started_at: started_at)
      end

      output
    end

    private

    def sentry_tracing_available?
      defined?(Sentry) &&
        Sentry.respond_to?(:initialized?) &&
        Sentry.initialized? &&
        Sentry.respond_to?(:with_child_span)
    end

    def sentry_report_name
      self.class.name.delete_suffix("Generator").underscore.humanize
    end

    def sentry_report_transaction_name
      "Report Generate / #{sentry_report_name}"
    end

    def current_sentry_scope
      Sentry.get_current_scope if Sentry.respond_to?(:get_current_scope)
    end

    def current_sentry_span
      scope = current_sentry_scope
      scope.get_span if scope&.respond_to?(:get_span)
    end

    def current_sentry_transaction
      scope = current_sentry_scope
      scope.get_transaction if scope&.respond_to?(:get_transaction)
    end

    def sentry_exporter_job_transaction?(transaction)
      transaction&.respond_to?(:name) && transaction.name == "ExporterJob"
    end

    def set_sentry_report_data(span, started_at:)
      sentry_base_report_attributes(started_at).merge(sentry_report_attributes).each do |key, value|
        span.set_data(key.to_s, value) if value.present?
      end
    end

    def set_sentry_report_transaction_data(transaction, started_at:)
      transaction.set_name(sentry_report_transaction_name, source: :task) if transaction.respond_to?(:set_name)
      transaction.set_data("op", "report.generate") if transaction.respond_to?(:set_data)
      set_sentry_report_data(transaction, started_at: started_at)
    end

    def set_sentry_report_result_data(span, output:, started_at:)
      span.set_data("duration_ms", ((Time.current - started_at) * 1000).round(1))
      span.set_data("output_bytes", output.bytesize) if output.respond_to?(:bytesize)
    end

    def generate_with_standalone_sentry_transaction(started_at)
      transaction = Sentry.start_transaction(
        name: sentry_report_transaction_name,
        source: :task,
        op: "report.generate",
        description: sentry_report_name
      ) if Sentry.respond_to?(:start_transaction)

      return yield unless transaction

      output = nil

      Sentry.with_scope do |scope|
        scope.set_span(transaction) if scope.respond_to?(:set_span)
        set_sentry_report_data(transaction, started_at: started_at)
        output = yield
        set_sentry_report_result_data(transaction, output: output, started_at: started_at)
        capture_sentry_report_generated(output: output, started_at: started_at)
      rescue Exception # rubocop:disable Lint/RescueException
        transaction.set_http_status(500) if transaction.respond_to?(:set_http_status)
        raise
      ensure
        transaction.finish if transaction.respond_to?(:finish)
      end

      output
    end

    def capture_sentry_report_generated(output:, started_at:)
      return unless Sentry.respond_to?(:capture_message)

      Sentry.with_scope do |scope|
        scope.set_level(:info) if scope.respond_to?(:set_level)
        scope.set_tags(sentry_report_event_tags) if scope.respond_to?(:set_tags)
        scope.set_extras(sentry_report_event_extras(output: output, started_at: started_at)) if scope.respond_to?(:set_extras)
        Sentry.capture_message("Report generated")
      end
    rescue StandardError
      nil
    end

    def sentry_report_event_tags
      {
        report: sentry_report_name.parameterize(separator: "_"),
        generator: self.class.name,
        source: sentry_report_value(:@source),
        type: sentry_report_value(:@type)
      }.reject { |_key, value| value.blank? }
    end

    def sentry_report_event_extras(output:, started_at:)
      result_attributes = {
        duration_ms: ((Time.current - started_at) * 1000).round(1),
        output_bytes: output.respond_to?(:bytesize) ? output.bytesize : nil
      }

      sentry_base_report_attributes(started_at)
        .merge(sentry_report_attributes)
        .merge(result_attributes)
        .reject { |_key, value| value.blank? }
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
