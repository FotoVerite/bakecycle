module OrderSearchMethods
  def search(fields)
    search_by_client(fields[:client_id])
      .search_by_route(fields[:route_id])
      .search_by_date(fields[:date])
      .search_by_product(fields[:product_id])
  end

  def search_by_client(client_id)
    return all if client_id.blank?
    where(client_id: client_id)
  end

  def search_by_route(route_id)
    return all if route_id.blank?
    where(route_id: route_id)
  end

  def search_by_date(date)
    return all if date.blank?
    where('start_date <= ?', date)
      .where('end_date >= ? OR end_date is NULL', date)
  end

  def search_by_product(product_id)
    return all if product_id.blank?
    joins(:order_items).where(order_items: { product_id: product_id })
  end
end
