require "faker"

FactoryGirl.define do
  factory :shipment_item do
    shipment
    product
    product_quantity { Faker::Number.number(2).to_i }
    price_per_item { Faker::Number.decimal(2) }
  end
end
