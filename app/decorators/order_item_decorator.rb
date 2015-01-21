class OrderItemDecorator < Draper::Decorator
  delegate_all

  def product_price_and_quantity
    "#{product_price} @#{weekly_quantity}pc" if product
  end

  def display_total_quantity_price
    "$#{total_quantity_price}" if product
  end
end
