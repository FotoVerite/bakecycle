class ShipmentSearcher
  def self.search(collection, terms)
    new(collection).search(terms)
  end

  def initialize(collection)
    @collection = collection
  end

  def search(terms)
    search_by_client(terms[:client_id])
    search_by_date_from(terms[:date_from])
    search_by_date_to(terms[:date_to])
    search_by_date(terms[:date])
    search_by_route(terms[:route_id])
    search_by_product(terms[:product_id])
    @collection.order(date: :desc)
  end

  private

  def search_by_date(date)
    return if date.blank?
    @collection = @collection.where(date: date)
  end

  def search_by_client(client_id)
    return if client_id.blank?
    @collection = @collection.where(client_id: client_id)
  end

  def search_by_route(route_id)
    return if route_id.blank?
    @collection = @collection.where(route_id: route_id)
  end

  def search_by_date_from(date_from)
    return if date_from.blank?
    @collection = @collection.where('date >= ?', date_from)
  end

  def search_by_date_to(date_to)
    return if date_to.blank?
    @collection = @collection.where('date <= ?', date_to)
  end

  def search_by_product(product_id)
    return if product_id.blank?
    @collection = @collection.joins(:shipment_items).where(shipment_items: { product_id: product_id })
  end
end
