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
    pdf.render
  end

  private

  def pdf
    production_run_data = ProductionRunData.new(@production_run)
    ProductionRunPdf.new(production_run_data)
  end
end
