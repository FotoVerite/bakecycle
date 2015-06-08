class ProductCounter
  attr_reader :date, :bakery

  def initialize(bakery, date)
    @bakery = bakery
    @date = date
  end

  def shipments
    @_shipments ||= Shipment.where(bakery: bakery)
      .where(date: date)
      .order(:route_departure_time, :route_name, :client_name)
  end

  def products
    @_products ||= Product.where(bakery: bakery, id: shipment_items.pluck(:product_id)).order(:name)
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
    end
    assign_overbake_count_and_product_total(@_product_counts)
  end

  def date_formatted
    date.strftime('%a %b. %e, %Y')
  end

  private

  def assign_overbake_count_and_product_total(product_counts)
    product_counts.each do |product_id, product_count|
      product_count[:overbake_count] = overbake_by_product[product_id] || 0
      product_count[:total] = product_count.values.sum
    end
    product_counts
  end

  def overbake_by_product
    @_run_items ||= RunItem.where(production_run_id: shipment_items.pluck(:production_run_id))
      .group(:product_id)
      .sum(:overbake_quantity)
  end

  def shipment_items
    @_shipment_items ||= ShipmentItem.where(shipment_id: shipments.pluck(:id))
  end

  def shipment_route_index
    @_shipment_route_index ||= shipments.pluck(:id, :route_id).to_h
  end
end
