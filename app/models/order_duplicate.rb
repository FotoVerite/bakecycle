class OrderDuplicate
  attr_reader :order

  def initialize(order)
    @order = order
  end

  def duplicate
    copy = duplicate_order
    copy.order_items = duplicate_items
    copy
  end

  private

  def duplicate_order
    copy = order.dup
    copy.assign_attributes(start_date: nil, end_date: nil)
    copy
  end

  def duplicate_items
    order.order_items.map(&:dup)
  end
end
