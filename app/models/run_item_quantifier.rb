class RunItemQuantifier
  attr_reader :run_item, :product, :order_quantity, :shipment_items

  def initialize(run_item)
    @run_item = run_item
    @product = run_item.product
    @shipment_items = run_item.shipment_items.for_product(product)
  end

  def set
    order_quantity
    overbake_quantity
  end

  def order_quantity
    run_item.order_quantity ||= shipment_items.quantities_sum
  end

  def overbake_quantity
    run_item.overbake_quantity = (order_quantity * product.over_bake / 100).ceil if shipment_items.any?
  end
end
