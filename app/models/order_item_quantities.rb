class OrderItemQuantities
  attr_reader :product, :ship_date, :end_date
  delegate :name, :total_lead_days, :over_bake, to: :product, prefix: true

  def initialize(order_items, start_date, end_date = nil)
    @order_items = order_items.uniq
    @start_date = start_date
    @product = @order_items.first.product
    @ship_date = start_date + product.total_lead_days.days
    @end_date = end_date
    validate_single_product
  end

  def order_quantity
    @_order_quantity ||= batch_quantities if end_date
    @_order_quantity ||= order_quantity_for_day(ship_date)
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

  def batch_quantities
    (@start_date..end_date).reduce(0) { |sum, date| sum + order_quantity_for_day(date + @product.total_lead_days.days) }
  end

  def order_quantity_for_day(date)
    @order_items.map { |order_item| order_item.quantity(date) }.sum
  end

  def validate_single_product
    return if @order_items.to_a.uniq(&:product_id).count == 1
    raise ArgumentError, 'Order Items must belong to the same product'
  end
end
