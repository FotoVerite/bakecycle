class ProjectionGenerator
  include GlobalID::Identification

  def self.find(global_id)
    bakery_id, start_date_string = global_id.split('_')
    bakery = Bakery.find(bakery_id)
    start_date = Date.iso8601(start_date_string)
    new(bakery, start_date)
  end

  def initialize(bakery, start_date)
    @bakery = bakery
    @start_date = start_date.to_date
  end

  def id
    "#{@bakery.id}_#{@start_date.iso8601}"
  end

  def filename
    'ProjectionRunRecipe.pdf'
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
