class ProductionRunProjectionService
  attr_reader :bakery, :start_date, :products_info

  def initialize(bakery, start_date)
    @bakery = bakery
    @start_date = start_date
    order_items
    group_by_product_and_count
  end

  def order_items
    @_order_items ||= active_order_items.can_start_on_date(start_date)
  end

  private

  def group_by_product_and_count
    @products_info = groups.collect do |group|
      create_product_info(group)
    end
  end

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
    OrderItem.where(order: orders)
  end

  def groups
    order_items.group_by(&:product)
  end
end
