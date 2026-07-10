# frozen_string_literal: true

class BatchGenerator
  include Generator
  composite_id bakery: :bakery, start_date: :date, end_date: :date

  def initialize(bakery, start_date, end_date)
    @bakery = bakery
    @start_date = start_date.to_date
    @end_date = end_date.to_date
  end

  def filename
    "Batch-Recipes-#{@start_date.iso8601}-to-#{@end_date.iso8601}.pdf"
  end

  def generate
    pdf.render
  end

  private

  def projection
    ProductionRunProjection.new(@bakery, @start_date, @end_date)
  end

  def projection_data
    ProjectionRunData.new(projection)
  end

  def pdf
    BatchRunPdf.new(projection_data)
  end
end
