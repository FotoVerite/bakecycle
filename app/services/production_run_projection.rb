class ProductionRunProjection
  attr_reader :bakery, :start_date

  def initialize(bakery, start_date)
    @bakery = bakery
    @start_date = start_date
  end

  def order_items
    @_order_items ||= active_order_items.can_start_on_date(start_date)
  end

  def products_info
    @_products_info ||= groups.collect do |group|
      create_product_info(group)
    end
  end

  private

  def create_product_info(group)
    product, order_items = group
    order_quantities = OrderItemQuantities.new(order_items, start_date)
    OpenStruct.new(
      product: product,
      order_quantity: order_quantities.order_quantity,
      overbake_quantity: order_quantities.overbake_quantity,
      total_quantity: order_quantities.total_quantity
    )
  end

  def orders
    bakery.orders.active(start_date)
  end

  def active_order_items
    OrderItem.where(order: orders).includes(product: [:inclusion, :motherdough])
  end

  def groups
    order_items.group_by(&:product)
  end
end
