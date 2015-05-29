class OrderItemQuantities
  attr_reader :product, :ready_date
  delegate :name, :total_lead_days, :over_bake, to: :product, prefix: true
  def initialize(order_items, start_date)
    @order_items = order_items
    @start_date = start_date
    @product = @order_items.first.product
    @ready_date = start_date + product.total_lead_days.days
    validate_single_product
  end

  def order_quantity
    @_order_quantity ||= @order_items.map { |order_item| order_item.quantity(ready_date) }.sum
  end

  def overbake_quantity
    @_overbake_quantity ||= (order_quantity * product.over_bake / 100).ceil
  end

  def total_quantity
    @_total_quantity ||= order_quantity + overbake_quantity
  end

  def product_type
    product.product_type.humanize(capitalize: false).titleize
  end

  private

  def validate_single_product
    return if @order_items.to_a.uniq(&:product_id).count == 1
    raise ArgumentError, 'Order Items must belong to the same product'
  end
end
