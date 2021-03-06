class ShipmentCreator
  attr_reader :order, :ship_date

  def initialize(order, ship_date)
    @order = order
    @ship_date = ship_date
  end

  def create!
    existing_shipment = Shipment.where(shipment_attributes).first
    return existing_shipment if existing_shipment
    return if shipment_items_is_empty_and_has_no_fee?
    create_shipment_transaction
  end

  private

  def create_shipment_transaction
    ActiveRecord::Base.transaction do
      create_shipment
    end
  end

  def shipment_items_is_empty_and_has_no_fee?
    shipment_items.empty? && delivery_fee.zero?
  end

  def create_shipment
    shipment = Shipment.create!(shipment_attributes) do |obj|
      obj.delivery_fee = delivery_fee
    end
    shipment_items.each do |item|
      item.shipment = shipment
      item.save!
    end
    shipment
  end

  def shipment_attributes
    {
      bakery_id: order.bakery_id,
      client_id: order.client_id,
      route_id: order.route_id,
      date: ship_date,
      auto_generated: true,
      order_id: order.id
    }
  end

  def shipment_items
    @_shipment_items ||= order.order_items.includes(product: [:price_variants]).map do |item|
      next unless item.quantity(ship_date) > 0
      ShipmentItem.new(
        product: item.product,
        product_quantity: item.quantity(ship_date),
        product_price: item.product_price
      )
    end.compact
  end

  def delivery_fee
    return @_delivery_fee if @_delivery_fee
    return @_delivery_fee = 0 unless charge_daily_fee? || charge_weekly_fee?
    @_delivery_fee = order.client_delivery_fee
  end

  def charge_daily_fee?
    return false unless order.client_daily_delivery_fee?
    return false if shipment_items.empty?
    shipment_items_subtotal < order.client_delivery_minimum
  end

  def charge_weekly_fee?
    order.client_weekly_delivery_fee? && ship_date.sunday? && weekly_subtotal_too_low?
  end

  def weekly_subtotal_too_low?
    (weekly_subtotal + shipment_items_subtotal) < order.client_delivery_minimum
  end

  def weekly_subtotal
    Shipment.weekly_subtotal(order.client_id, ship_date)
  end

  def shipment_items_subtotal
    shipment_items.sum(&:price)
  end
end
