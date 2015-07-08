class ShipmentsDecorator < Draper::CollectionDecorator
  delegate :current_page, :per_page, :offset, :total_entries, :total_pages

  def available_clients
    h.item_finder.clients.order_by_name
  end

  def available_products
    h.item_finder.products.order_by_name
  end

  def price_total
    h.number_to_currency object.to_a.sum(&:price)
  end
end
