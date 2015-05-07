class OrderDuplicate
  attr_accessor :order, :order_dup

  def initialize(order)
    @order = order
    @order_dup = order.dup
    duplicate_order_items
  end

  def duplicate_order_items
    order.order_items.each do |order_item|
      order_dup.order_items << order_item.dup
    end
  end
end
