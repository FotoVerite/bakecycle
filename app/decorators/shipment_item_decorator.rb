class ShipmentItemDecorator < Draper::Decorator
  delegate_all

  def product_price
    h.number_to_currency(object.product_price)
  end

  def float_product_price
    object.product_price.to_f
  end

  def product_type
    object.product_product_type.humanize(capitalize: false).titleize
  end

  def price
    h.number_to_currency(object.price)
  end

  def price_for_iif
    if object.price > 0
      "-#{object.price}"
    else
      "#{object.price.abs}"
    end
  end

  def product_price_for_iif
    object.product_price
  end

  def product_quantity_for_iif
    if object.product_quantity > 0
      "-#{object.product_quantity}"
    else
      object.product_quantity.abs.to_s
    end
  end

  def product_name_and_sku
    return "#{product_sku}-#{product_name}" if product_sku.present?
    product_name
  end
end
