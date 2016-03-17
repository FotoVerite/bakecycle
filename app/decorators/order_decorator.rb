class OrderDecorator < Draper::Decorator
  delegate_all
  decorates_association :order_items
  decorates_association :overlapping_orders
  decorates_association :overridable_order

  def route_name
    route.name if route
  end

  def type
    order_type.humanize(capitalize: false).titleize
  end

  def available_products
    h.item_finder.products.order(:name)
  end

  def available_routes
    h.item_finder.routes.active.order(:name)
  end

  def available_clients
    h.item_finder.clients.order(:name)
  end

  def upcoming_shipments
    object.shipments.upcoming(Time.zone.today).decorate
  end

  def overridable_end_date
    object.start_date - 1.day
  end
end
