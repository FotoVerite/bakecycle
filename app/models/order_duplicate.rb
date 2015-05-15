class OrderDuplicate
  attr_accessor :order, :order_dup

  def initialize(order)
    @order = order
    @order_dup = order.dup
    duplicate_order_items
  end

  private

  def duplicate_order_items
    order_dup.order_items = order.order_items.map(&:dup)
  end
end
