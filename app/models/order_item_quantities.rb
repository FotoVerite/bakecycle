class OrderItemQuantities
  attr_reader :product
  def initialize(order_items, start_date)
    @order_items = order_items
    @start_date = start_date
    validate_single_product
  end

  def order_quantity
    # what is this magic!?
    @_order_quantity ||= @order_items.map(&ready_on_weekday).sum
  end

  def overbake_quantity
    @_overbake_quantity ||= (order_quantity * product.over_bake / 100).ceil
  end

  def total_quantity
    @_total_quantity ||= order_quantity + overbake_quantity
  end

  private

  def validate_single_product
    @product = @order_items.first.product
    return if @order_items.to_a.uniq(&:product_id).count == 1
    raise ArgumentError, 'Order Items must belong to the same product'
  end

  def ready_on_weekday
    (@start_date + product.total_lead_days.days).strftime('%A').downcase.to_sym
  end
end
