# == Schema Information
#
# Table name: price_variants
#
#  id         :integer          not null, primary key
#  product_id :integer          not null
#  price      :decimal(, )      default(0.0), not null
#  quantity   :integer          not null
#  created_at :datetime
#  updated_at :datetime
#  client_id  :integer
#  removed    :integer          default(0)
#

class PriceVariantSerializer < ActiveModel::Serializer
  attributes :id, :price, :quantity, :errors, :client_id
end
