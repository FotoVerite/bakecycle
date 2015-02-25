class ShipmentService
  def self.run
    Bakery.find_each do |bakery|
      process_bakery(bakery)
    end
  end

  def self.process_bakery(bakery)
    Client.where(bakery: bakery).find_each do |client|
      process_client(client)
    end
  end

  def self.process_client(client)
    max_lead_time = client.orders.map(&:lead_time).max
    return if max_lead_time.nil?
    (1..max_lead_time).to_a.each do |lead|
      ship_date = Date.today + lead.days
      Order.active(client, ship_date).each do |order|
        ship_order(order, ship_date)
      end
    end
  end

  def self.ship_order(order, ship_date)
    Shipment.where(
      bakery: order.bakery,
      client_id: order.client.id,
      route_id: order.route.id,
      date: ship_date,
      auto_generated: true
    ).first_or_create! do |shipment|
      shipment.shipment_items = shipment_items(order.order_items, ship_date)
    end
  end

  def self.shipment_items(order_items, ship_date)
    order_items.map do |item|
      ShipmentItem.new(
        product_id: item.product.id,
        product_quantity: item.quantity(ship_date),
        product_price: item.product_price
      )
    end
  end
end
