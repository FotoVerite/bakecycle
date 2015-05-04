class ProductionRunProjection
  attr_reader :bakery, :start_date

  def initialize(bakery, start_date)
    @bakery = bakery
    @start_date = start_date
  end

  def order_items
    @_order_items ||= bakery
      .order_items
      .production_start_on?(start_date)
      .select { |order_item| order_item.production_start_on?(start_date) }
  end

  def products_info
    @_products_info ||= groups.collect do |(_product, grouped_order_items)|
      OrderItemQuantities.new(grouped_order_items, start_date)
    end.compact
  end

  private

  def groups
    order_items.group_by(&:product)
  end
end
