FactoryGirl.define do
  factory :shipment_item do
    transient do
      bakery { build(:bakery) }
    end
    shipment { create(:shipment, bakery: bakery) }
    product { create(:product, bakery: bakery) }
    product_quantity { Faker::Number.number(2) }
    product_price { Faker::Number.decimal(2) }
  end
end
