class ShipmentService
  attr_reader :bakery, :run_time

  def self.run(run_time = Time.now)
    Bakery.find_each do |bakery|
      new(bakery, run_time).run
    end
  end

  def initialize(bakery, run_time)
    @bakery = bakery
    @run_time = run_time
  end

  def run
    return unless kickoff?
    bakery.update!(last_kickoff: run_time)
    process_bakery
  end

  def kickoff?
    after_kickoff_time? && kickoff_expired?
  end

  def process_bakery
    Client.where(bakery: bakery).find_each do |client|
      process_client(client)
    end
  end

  def process_client(client)
    max_lead_time = client.orders.map(&:total_lead_days).max
    return if max_lead_time.nil?
    (1..max_lead_time).each do |lead|
      ship_date = run_time + lead.days
      Order.active(client, ship_date).each do |order|
        ship_order(order, ship_date)
      end
    end
  end

  def ship_order(order, ship_date)
    shipment_items = shipment_items(order.order_items, ship_date)
    return unless shipment_items.any?
    Shipment.where(
      bakery: order.bakery,
      client_id: order.client.id,
      route_id: order.route.id,
      date: ship_date,
      auto_generated: true
    ).first_or_create! do |shipment|
      shipment.shipment_items = shipment_items
      shipment.delivery_fee = delivery_fee(order, ship_date)
    end
  end

  def shipment_items(order_items, ship_date)
    order_items.map do |item|
      next unless item.quantity(ship_date) > 0
      ShipmentItem.new(
        product_id: item.product.id,
        product_quantity: item.quantity(ship_date),
        product_price: item.product_price
      )
    end.compact
  end

  def delivery_fee(order, ship_date)
    return 0 unless order.client_daily_delivery_fee?
    return 0 unless order.daily_subtotal(ship_date) < order.client_delivery_minimum
    order.client_delivery_fee
  end

  private

  def after_kickoff_time?
    kickoff = bakery.kickoff_time
    kickoff_today = Time.new(run_time.year, run_time.month, run_time.day, kickoff.hour, kickoff.min, kickoff.sec)
    kickoff_today < run_time
  end

  def kickoff_expired?
    return true unless bakery.last_kickoff
    (bakery.last_kickoff + 24.hours) < run_time
  end
end
