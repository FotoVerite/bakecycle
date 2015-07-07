class ProductionRunProjection
  attr_reader :bakery, :start_date, :batch_end_date

  def initialize(bakery, start_date, end_date = nil)
    @bakery = bakery
    @start_date = start_date.to_date
    @batch_end_date = end_date.to_date if end_date
  end

  def order_items
    return @_order_items ||= batched_order_items if batch_end_date
    @_order_items ||= order_items_for(start_date)
  end

  def products_info
    @_products_info ||= groups.collect do |(_product, grouped_order_items)|
      OrderItemQuantities.new(grouped_order_items, start_date, batch_end_date)
    end
  end

  private

  def batched_order_items
    (@start_date..batch_end_date).map { |date| batch_order_items_for(date) }.flatten.uniq
  end

  def order_items_for(start_date)
    bakery
      .order_items
      .production_start_on?(start_date)
      .order_by_product_type_and_name
      .select { |order_item| order_item.production_start_on?(start_date) }
  end

  def batch_order_items_for(date)
    bakery
      .order_items.includes(:product)
      .where('products.batch_recipe' => true)
      .production_start_on?(date)
      .order_by_product_type_and_name
      .select { |order_item| order_item.production_start_on?(date) }
  end

  def groups
    order_items.group_by(&:product)
  end
end
