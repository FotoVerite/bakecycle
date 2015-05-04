class ProductCounter
  attr_reader :date, :bakery

  def initialize(date, bakery)
    @bakery = bakery
    @date = date
  end

  def shipments
    @_shipments ||= Shipment.where(bakery: bakery).search_by_date(date)
  end

  def products
    @_products ||= Product.where(bakery: bakery, id: shipment_items.pluck(:product_id))
  end

  def product_types
    @_product_types ||= products.pluck(:product_type).uniq.sort
  end

  def routes
    @_routes ||= Route.where(bakery: bakery, id: shipments.pluck(:route_id)).order('departure_time ASC')
  end

  def route_shipment_clients(route)
    clients_id = Shipment.where(route_id: route.id).pluck(:client_id).uniq
    Client.where(bakery: bakery, id: clients_id).decorate
  end

  def product_counts
    return @_product_counts if @_product_counts
    @_product_counts = shipment_items.each_with_object({}) do |item, count|
      route_id = shipment_route_index[item.shipment_id]
      product_id = item.product_id
      count[product_id] = Hash.new(0) unless count[product_id]
      count[product_id][route_id] += item.product_quantity
      count[product_id][:total] += item.product_quantity
    end
  end

  def date_formatted
    date.strftime('%a %b. %e, %Y')
  end

  private

  def shipment_items
    @_shipment_items ||= ShipmentItem.where(shipment_id: shipments.pluck(:id))
  end

  def shipment_route_index
    @_shipment_route_index ||= shipments.pluck(:id, :route_id).to_h
  end
end
