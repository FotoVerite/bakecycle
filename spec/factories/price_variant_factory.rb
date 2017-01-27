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
#

FactoryGirl.define do
  factory :price_variant do
    product
    price { Faker::Number.decimal(2) }
    quantity { Faker::Number.number(2) }
  end
end
