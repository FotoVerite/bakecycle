require "faker"

FactoryGirl.define do
  factory :shipment_item do
    shipment
    transient do
      bakery { build(:bakery) }
    end
    product { create(:product, bakery: bakery) }
    product_quantity { Faker::Number.number(2) }
    product_price { Faker::Number.decimal(2) }
  end
end
