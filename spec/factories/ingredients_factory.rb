require 'faker'

FactoryGirl.define do
  factory :ingredient do
    sequence(:name) { |n| "#{n}#{Faker::Lorem.word}" }
    price { Faker::Number.decimal(3) }
    measure { Faker::Number.decimal(0, 3) }
    unit [:oz, :lb, :g, :kg].sample
    ingredient_type [:flour, :ingredient].sample
    description { Faker::Lorem.sentence(1) }
  end
end
