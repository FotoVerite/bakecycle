class BatchGenerator
  include GlobalID::Identification

  def self.find(global_id)
    bakery_id, start_date_string, end_date_string = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    start_date = Date.iso8601(start_date_string)
    end_date = Date.iso8601(end_date_string)
    new(bakery, start_date, end_date)
  end

  def initialize(bakery, start_date, end_date)
    @bakery = bakery
    @start_date = start_date.to_date
    @end_date = end_date.to_date
  end

  def id
    "#{@bakery.id}_#{@start_date.iso8601}_#{@end_date.iso8601}"
  end

  def filename
    "BatchRecipes.pdf"
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
