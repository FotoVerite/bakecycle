class ShipmentService
  attr_reader :bakery, :run_time

  def self.lookup_lead_time(product)
    @product_time_cache ||= {}
    @product_time_cache[product.id] ||= product.total_lead_days
  end

  def initialize(bakery, run_time)
    @bakery = bakery
    @run_time = run_time
  end

  def run
    process_bakery
  end

  private

  def process_bakery
    orders_ready_for_production.each do |order|
      (1..order.total_lead_days).each do |lead|
        ship_date = run_time + lead.days
        ShipmentCreator.new(order, ship_date).create!
      end
    end
  end

  def orders_ready_for_production
    bakery.order_items.production_start_on?(run_time).map(&:order).uniq
  end

  def max_lead_time(products)
    products.map { |product| ShipmentService.lookup_lead_time(product) }.max
  end
end
