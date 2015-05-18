class ProductionRunService
  attr_reader :bakery, :production_run, :date

  def initialize(bakery, date = Time.zone.now)
    @bakery = bakery
    @date = date
  end

  def run
    ActiveRecord::Base.transaction do
      find_or_create_production_run
      associate_shipment_items
      create_or_update_run_items
    end
  end

  private

  def associate_shipment_items
    shipment_items.update_all(production_run_id: production_run.id)
  end

  def shipment_items
    @_shipment_items ||= bakery.shipment_items.where(production_start: date)
      .where('production_run_id IS NULL OR production_run_id = ?', production_run.id)
  end

  def create_or_update_run_items
    products = Product.where(id: shipment_items.map(&:product_id))
    production_run.run_items = products.map { |product| make_run_item(product) }
  end

  def make_run_item(product)
    RunItem.where(product: product, production_run_id: production_run.id)
      .first_or_initialize
      .tap { |run_item| update_run_item(run_item, product) }
  end

  def update_run_item(run_item, product)
    run_item.shipment_items = shipment_items_for(product)
    run_item.save!
  end

  def shipment_items_for(product)
    shipment_items.select { |item| item.product_id == product.id }
  end

  def find_or_create_production_run
    @production_run = ProductionRun.where(bakery: bakery, date: date).first_or_create
  end
end
