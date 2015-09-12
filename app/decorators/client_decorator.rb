class ClientDecorator < Draper::Decorator
  delegate_all

  decorates_association :orders

  def active_status
    active ? "Yes" : "No"
  end

  def billing
    billing_term.humanize(capitalize: false).titleize if billing_term
  end

  def delivery_fee_display
    delivery_fee_option.humanize(capitalize: false).titleize if delivery_fee_option
  end

  def latest_orders
    object.orders.includes(:route).latest(10).decorate
  end

  def latest_shipments
    object.shipments.includes(:shipment_items).latest(10).decorate
  end

  def serializable_hash
    ClientSerializer.new(client).serializable_hash
  end
end
