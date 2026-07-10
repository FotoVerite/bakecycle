# frozen_string_literal: true

module Generator
  TRACER = defined?(OpenTelemetry) ? OpenTelemetry.tracer_provider.tracer("bakecycle-reports") : nil

  def self.included(base)
    base.include GlobalID::Identification
    base.prepend Instrumentation
    base.extend CompositeId::ClassMethods
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

  # Declarative GlobalID composite-id support. Most report generators are just
  # a bakery plus a handful of scalars (dates, a type string, a flag) -- before
  # this, every one of those classes hand-rolled its own `.find`/`#id` pair,
  # splitting `global_id` on "_" and coercing each piece by hand. That parsing
  # is pure plumbing (GlobalID needs *some* string to round-trip a generator
  # through ActiveJob serialization), not per-report behavior, so it belongs
  # here once instead of copied ~23 times.
  #
  # Usage: `composite_id bakery: :bakery, date: :date, type: :string`. Keys are
  # both the constructor's positional parameter names AND the instance variable
  # each is assigned to (i.e. `@date`); values pick a coercer/serializer pair
  # below. `.find` reconstructs the instance via `new(*args)` in declared
  # order, so declaration order must match the constructor's.
  #
  # Deliberately NOT used by every generator: a few (ProductTotalsDateRangeGenerator,
  # TestProjectionGenerator) have real per-report parsing logic beyond "split
  # and coerce a scalar," and a few more (InvoicePdfGenerator and its siblings)
  # resolve a second field through an association lookup rather than a plain
  # coercer -- forcing those through this DSL would hide real behavior behind
  # it, not remove boilerplate.
  module CompositeId
    COERCERS = {
      bakery: ->(value) { Bakery.find(value) },
      date: ->(value) { Date.iso8601(value) },
      string: ->(value) { value },
      bool: ->(value) { value == "true" }
    }.freeze

    SERIALIZERS = {
      bakery: ->(value) { value.id },
      date: ->(value) { value.to_date.iso8601 },
      string: ->(value) { value },
      bool: ->(value) { value }
    }.freeze

    module ClassMethods
      def composite_id(**fields)
        define_singleton_method(:find) do |global_id|
          values = global_id.split("_", fields.size)
          args = fields.values.zip(values).map { |type, value| COERCERS.fetch(type).call(value) }
          new(*args)
        end

        define_method(:id) do
          fields.map { |name, type| SERIALIZERS.fetch(type).call(instance_variable_get(:"@#{name}")) }.join("_")
        end
      end
    end
  end
end
