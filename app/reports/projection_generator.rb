# frozen_string_literal: true

class ProjectionGenerator
  include Generator
  composite_id bakery: :bakery, start_date: :date

  def initialize(bakery, start_date)
    @bakery = bakery
    @start_date = start_date.to_date
  end

  def filename
    "Production-Run-Projection-#{@start_date.iso8601}.pdf"
  end

  def generate
    pdf.render
  end

  private

  def pdf
    projection = ProductionRunProjection.new(@bakery, @start_date)
    projection_data = ProjectionRunData.new(projection)
    ProductionRunPdf.new(projection_data)
  end
end
