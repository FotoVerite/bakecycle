class ProductionRunService
  attr_reader :bakery, :production_run, :date

  def initialize(bakery, date = Time.zone.now)
    @bakery = bakery
    @production_run = ProductionRun.create(bakery: bakery, date: date)
    @date = date
  end

  def run
    associate_shipment_items
    create_run_items
    production_run
  end

  def associate_shipment_items
    eligible_shipment_items.each do |shipment_item|
      shipment_item.update(production_run: production_run)
    end
  end

  def create_run_items
    shipment_items = production_run.shipment_items
    return unless shipment_items
    products = Product.where(id: shipment_items.map(&:product_id))
    products.each do |product|
      RunItem.create(product: product, production_run: production_run)
    end
  end

  def eligible_shipment_items
    bakery.shipment_items.where(production_start: date, production_run: nil)
  end
end
