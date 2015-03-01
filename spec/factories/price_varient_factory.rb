FactoryGirl.define do
  factory :price_varient do
    product
    price { Faker::Number.decimal(2) }
    quantity Faker::Number.number(2)
    effective_date  { Date.today + Faker::Number.number(1).to_i.days }
  end
end
