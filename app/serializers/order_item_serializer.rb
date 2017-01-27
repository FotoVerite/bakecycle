# == Schema Information
#
# Table name: order_items
#
#  id              :integer          not null, primary key
#  order_id        :integer          not null
#  product_id      :integer          not null
#  monday          :integer          not null
#  tuesday         :integer          not null
#  wednesday       :integer          not null
#  thursday        :integer          not null
#  friday          :integer          not null
#  saturday        :integer          not null
#  sunday          :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  total_lead_days :integer          not null
#

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
