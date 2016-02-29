class OrderItemSerializer < ActiveModel::Serializer
  attributes :id,
    :product_id,
    :total_lead_days,
    :monday,
    :tuesday,
    :wednesday,
    :thursday,
    :friday,
    :saturday,
    :sunday,
    :product_price_and_quantity,
    :total_quantity_price,
    :total_quantity_price_currency

  def product_price_and_quantity
    object.decorate.product_price_and_quantity
  end

  def total_quantity_price_currency
    object.decorate.total_quantity_price_currency
  end
end
