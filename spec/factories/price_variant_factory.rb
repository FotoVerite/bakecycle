FactoryGirl.define do
  factory :price_variant do
    product
    price { Faker::Number.decimal(2) }
    quantity { Faker::Number.number(2) }
  end
end
