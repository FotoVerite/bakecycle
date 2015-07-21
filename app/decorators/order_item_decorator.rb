class OrderItemDecorator < Draper::Decorator
  delegate_all

  def product_price_and_quantity
    "#{h.number_to_currency(product_price)} @#{total_quantity}pc" if product
  end

  def total_quantity_price_currency
    h.number_to_currency(total_quantity_price) if product
  end
end
