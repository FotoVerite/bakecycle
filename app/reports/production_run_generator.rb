# frozen_string_literal: true

class ProductionRunGenerator
  include Generator

  def self.find(global_id)
    production_run = ProductionRun.find(global_id)
    new(production_run)
  end

  def initialize(production_run)
    @production_run = production_run
  end

  delegate :id, to: :@production_run

  def filename
    "Production-Run-#{@production_run.id}-#{@production_run.date}.pdf"
  end

  def generate
    render_pdf(build_production_run_data)
  end

  # Merged onto the report.generate span by Generator::Instrumentation.
  #
  # `bakery.id` is included here too, not just on ExporterJob's outer span --
  # Honeycomb span attributes don't inherit to child spans the way the
  # frontend's resource attribute does (see docs/honeycomb-rails-pitfalls.md,
  # "Attribute naming conventions"), so without this, a query scoped to
  # report.generate events specifically couldn't filter by tenant at all.
  def report_attributes
    {
      "production_run.id" => @production_run.id,
      "production_run.item_count" => @production_run.run_items.size,
      "bakery.id" => @production_run.bakery_id.to_s
    }
  end

  private

  # Split into two child spans so a slow trace can tell "assembling the
  # nested-recipe/product data" (Ruby-side graph walk plus its own DB
  # queries) apart from "Prawn laying out and rendering the PDF" -- both
  # previously landed as undifferentiated time inside the one report.generate
  # span.
  def build_production_run_data
    in_report_span("production_run.build_data") { ProductionRunData.new(@production_run) }
  end

  def render_pdf(production_run_data)
    in_report_span("production_run.render_pdf") { ProductionRunPdf.new(production_run_data).render }
  end

  def in_report_span(name, &block)
    return block.call unless Generator::TRACER

    Generator::TRACER.in_span(name, &block)
  end
end
