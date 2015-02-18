class ShipmentItemDecorator < Draper::Decorator
  delegate_all

  def product_price
    h.number_to_currency(object.product_price)
  end

  def price
    h.number_to_currency(object.price)
  end
end
