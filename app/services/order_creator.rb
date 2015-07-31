class OrderCreator
  attr_reader :order, :confirm_override, :overrideable, :updated_id

  def initialize(order, confirm_override = nil)
    @order = order
    @confirm_override = confirm_override
    @overrideable = order.overridable_order
  end

  def run
    order.validate
    if confirm_override && order.overridable_order?
      update_orders
    else
      order.save
    end
  end

  def success_message
    "You have created a #{@order.order_type} order for #{@order.client_name}."
  end

  private

  def update_orders
    binding
    if overrideable.update(end_date: order.start_date - 1.day)
      @updated_id = overrideable.id
      order.save
    else
      order.errors.add(:base, "Could not override overlapping order, please update it manually.")
      false
    end
  end

  def overlap_errors_only?
    order.errors.count == 2 && order.errors[:start_date].join.include?("overlap")
  end
end
