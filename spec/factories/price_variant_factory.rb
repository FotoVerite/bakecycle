# frozen_string_literal: true

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

FactoryBot.define do
  factory :price_variant do
    product { create(:product) }
    price { Faker::Number.decimal(l_digits: 2) }
    quantity { Faker::Number.number(digits: 2) }
  end
end
