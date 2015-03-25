class RunItemQuantifier
  attr_reader :run_item, :product, :order_quantity

  def initialize(run_item)
    @run_item = run_item
    @product = run_item.product
  end

  def set
    order_quantity
    overbake_quantity
    total_quantity
  end

  def order_quantity
    run_item.order_quantity ||= run_item.shipment_items.for_product(product).quantities_sum
  end

  def overbake_quantity
    run_item.overbake_quantity = (order_quantity * product.over_bake / 100).ceil
  end

  def total_quantity
    run_item.total_quantity = order_quantity + overbake_quantity
  end
end
