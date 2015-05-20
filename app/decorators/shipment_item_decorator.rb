class ShipmentItemDecorator < Draper::Decorator
  delegate_all

  def product_price
    h.number_to_currency(object.product_price)
  end

  def product_type
    object.product_product_type.humanize(capitalize: false).titleize
  end

  def price
    h.number_to_currency(object.price)
  end

  def price_for_iif
    "-#{object.price}"
  end

  def product_price_for_iif
    object.product_price
  end

  def product_quantity_for_iif
    "-#{object.product_quantity}"
  end

  def product_name_and_sku
    return "#{product_sku}-#{product_name}" if product_sku.present?
    product_name
  end
end
