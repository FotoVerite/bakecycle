require 'faker'

FactoryGirl.define do
  factory :ingredient do
    sequence(:name) { |n| "#{n}#{Faker::Lorem.word}" }
    price { Faker::Number.decimal(l_digits = 3) }
    measure { Faker::Number.decimal(l_digits = 0, r_digits = 3) }
    unit [:oz, :lb, :g, :kg].sample
    description {Faker::Lorem.sentence(1)}
  end
end
