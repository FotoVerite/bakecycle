class OrdersDecorator < Draper::CollectionDecorator
  delegate :current_page, :per_page, :offset, :total_entries, :total_pages

  def available_clients
    h.item_finder.clients.active.order_by_name
  end

  def available_routes
    h.item_finder.routes.active.order_by_name
  end

  def available_products
    h.item_finder.products.order_by_name
  end
end
