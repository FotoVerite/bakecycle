class OrderItemDecorator < Draper::Decorator
  delegate_all

  def product_price_and_quantity
    "#{h.number_to_currency(product_price, precision: 2)} @#{total_quantity}pc" if product
  end
end
