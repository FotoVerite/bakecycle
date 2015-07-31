class RunItemQuantifier
  attr_reader :run_item, :product, :shipment_items

  def initialize(run_item, shipment_items)
    @run_item = run_item
    @shipment_items = shipment_items
    @product = run_item.product
    validate_shipment_items
  end

  def set
    set_order_quantity
    set_overbake_quantity
  end

  private

  def validate_shipment_items
    return unless shipment_items.detect { |item| item.product_id != run_item.product_id }
    raise ArgumentError, "run_item and shipment items have different products"
  end

  def set_order_quantity
    run_item.order_quantity = ordered_quantity
  end

  def set_overbake_quantity
    run_item.overbake_quantity = (ordered_quantity * product.over_bake / 100).ceil
  end

  def ordered_quantity
    @_ordered_quantity ||= shipment_items.reduce(0) { |a, e| a + e.product_quantity }
  end
end
