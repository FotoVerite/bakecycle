class OrderDecorator < Draper::Decorator
  delegate_all
  decorates_association :order_items

  def type
    order_type.humanize(capitalize: false).titleize
  end

  def available_products
    h.item_finder.products.order(:name)
  end

  def available_routes
    h.item_finder.routes.order(:name)
  end

  def available_clients
    h.item_finder.clients.order(:name)
  end
end
