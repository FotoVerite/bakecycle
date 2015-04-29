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
    lead_time =  max_lead_time(bakery.products)
    return if lead_time.nil?
    (1..lead_time).each do |lead|
      ship_date = run_time + lead.days
      bakery.orders.includes(:client, :route, order_items: [:product]).active(ship_date).find_each do |order|
        ShipmentCreator.new(order, ship_date).create!
      end
    end
  end

  def max_lead_time(products)
    products.map { |product| ShipmentService.lookup_lead_time(product) }.max
  end
end
