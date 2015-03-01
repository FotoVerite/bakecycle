class RecipeService
  attr_reader :date

  def initialize(date)
    @date = date
  end

  def shipments
    @_shipments ||= Shipment.search_by_date(date)
  end

  def shipment_items
    @_shipment_items ||= ShipmentItem.where(shipment_id: shipments.pluck(:id))
  end

  def products
    @_products ||= Product.where(id: shipment_items.pluck(:product_id))
  end

  def product_types
    @_product_types ||= products.pluck(:product_type).uniq.sort
  end

  def routes
    @_routes ||= Route.where(id: shipments.pluck(:route_id)).order('departure_time ASC')
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

  private

  def shipment_route_index
    @_shipment_route_index ||= shipments.pluck(:id, :route_id).to_h
  end
end
