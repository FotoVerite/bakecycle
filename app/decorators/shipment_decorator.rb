class ShipmentDecorator < Draper::Decorator
  delegate_all

  def available_clients
    h.item_finder.clients.order(:name)
  end

  def available_routes
    h.item_finder.routes.order(:name)
  end

  def available_products
    h.item_finder.products.order(:name)
  end

  def auto_generated?
    auto_generated ? "Yes" : "No"
  end
end
