# frozen_string_literal: true

require "rails_helper"

describe Generator::Instrumentation do
  class InstrumentedTestGenerator
    include Generator

    def id
      "instrumented-test"
    end

    def filename
      "instrumented-test.csv"
    end

    def generate
      "report-output"
    end
  end

  class FakeSentryScope
    attr_reader :span

    def initialize(span: nil, transaction: nil)
      @span = span
      @transaction = transaction
    end

    def get_span
      @span
    end

    def get_transaction
      @transaction
    end

    def set_span(span)
      @span = span
    end
  end

  class FakeSentrySpan
    attr_reader :data

    def initialize(name: nil)
      @name = name
      @data = {}
      @finished = false
      @http_status = nil
    end

    attr_reader :name, :http_status

    def set_name(name, source: :custom)
      @name = name
      @source = source
    end

    def set_data(key, value)
      @data[key] = value
    end

    def set_http_status(status)
      @http_status = status
    end

    def finish
      @finished = true
    end

    def finished?
      @finished
    end
  end

  subject(:generator) { InstrumentedTestGenerator.new }

  before do
    allow(Sentry).to receive(:initialized?).and_return(true)
  end

  it "renames and annotates the generic ExporterJob transaction" do
    transaction = FakeSentrySpan.new(name: "ExporterJob")
    scope = FakeSentryScope.new(span: transaction, transaction: transaction)

    allow(Sentry).to receive(:get_current_scope).and_return(scope)

    expect(generator.generate).to eq("report-output")
    expect(transaction.name).to eq("Report Generate / Instrumented test")
    expect(transaction.data).to include(
      "generator" => "InstrumentedTestGenerator",
      "generator_id" => "instrumented-test",
      "filename" => "instrumented-test.csv",
      "content_type" => "text/csv",
      "output_bytes" => 13
    )
  end

  it "uses a child span inside a non-exporter transaction" do
    transaction = FakeSentrySpan.new(name: "ReportsController#create")
    child_span = FakeSentrySpan.new
    scope = FakeSentryScope.new(span: transaction, transaction: transaction)

    allow(Sentry).to receive(:get_current_scope).and_return(scope)
    allow(Sentry).to receive(:with_child_span).and_yield(child_span)

    expect(generator.generate).to eq("report-output")
    expect(transaction.name).to eq("ReportsController#create")
    expect(child_span.data).to include(
      "generator" => "InstrumentedTestGenerator",
      "output_bytes" => 13
    )
  end

  it "starts a standalone report transaction when no span is active" do
    transaction = FakeSentrySpan.new(name: "Report Generate / Instrumented test")
    scope = FakeSentryScope.new

    allow(Sentry).to receive(:get_current_scope).and_return(scope)
    allow(Sentry).to receive(:start_transaction).and_return(transaction)
    allow(Sentry).to receive(:with_scope).and_yield(scope)

    expect(generator.generate).to eq("report-output")
    expect(scope.span).to eq(transaction)
    expect(transaction).to be_finished
    expect(transaction.data).to include(
      "generator" => "InstrumentedTestGenerator",
      "output_bytes" => 13
    )
  end
end
