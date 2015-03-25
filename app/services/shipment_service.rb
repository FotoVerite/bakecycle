class ShipmentService
  def self.run(date = Date.today)
    Bakery.find_each do |bakery|
      process_bakery(bakery, date)
    end
  end

  def self.process_bakery(bakery, date)
    Client.where(bakery: bakery).find_each do |client|
      process_client(client, date)
    end
  end

  def self.process_client(client, date)
    max_lead_time = client.orders.map(&:total_lead_days).max
    return if max_lead_time.nil?
    (1..max_lead_time).to_a.each do |lead|
      ship_date = date + lead.days
      Order.active(client, ship_date).each do |order|
        ship_order(order, ship_date)
      end
    end
  end

  def self.ship_order(order, ship_date)
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

  def self.shipment_items(order_items, ship_date)
    order_items.map do |item|
      next unless item.quantity(ship_date) > 0
      ShipmentItem.new(
        product_id: item.product.id,
        product_quantity: item.quantity(ship_date),
        product_price: item.product_price
      )
    end.compact
  end

  def self.delivery_fee(order, ship_date)
    return 0 unless order.client_daily_delivery_fee?
    return 0 unless order.daily_subtotal(ship_date) < order.client_delivery_minimum
    order.client_delivery_fee
  end
end
