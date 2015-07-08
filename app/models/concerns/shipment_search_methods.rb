module ShipmentSearchMethods
  def search(fields)
    search_by_client(fields[:client_id])
      .search_by_date_from(fields[:date_from])
      .search_by_date_to(fields[:date_to])
      .search_by_date(fields[:date])
      .search_by_route(fields[:route_id])
      .search_by_product(fields[:product_id])
      .order('date DESC')
  end

  def shipments_for_week(client_id, end_date)
    week = Week.new(end_date)
    search_by_client(client_id)
      .search_by_date_from(week.start_date)
      .search_by_date_to(week.end_date)
  end

  def search_by_date(date)
    return all if date.blank?
    where(date: date)
  end

  def search_by_client(client_id)
    return all if client_id.blank?
    where(client_id: client_id)
  end

  def search_by_route(route_id)
    return all if route_id.blank?
    where(route_id: route_id)
  end

  def search_by_date_from(date_from)
    return all if date_from.blank?
    where('date >= ?', date_from)
  end

  def search_by_date_to(date_to)
    return all if date_to.blank?
    where('date <= ?', date_to)
  end

  def search_by_product(product_id)
    return all if product_id.blank?
    joins(:shipment_items).where(shipment_items: { product_id: product_id })
  end
end
