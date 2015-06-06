class ProductionRunGenerator
  include GlobalID::Identification

  def self.find(global_id)
    production_run = ProductionRun.find(global_id)
    new(production_run)
  end

  def initialize(production_run)
    @production_run = production_run
  end

  def id
    @production_run.id
  end

  def filename
    'ProductionRunRecipe.pdf'
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
