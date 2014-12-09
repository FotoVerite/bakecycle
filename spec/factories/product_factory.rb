require 'faker'

FactoryGirl.define do
  factory :product do
    sequence(:name) { |n| "#{n}#{Faker::Lorem.word}" }
    product_type [:bread, :vienoisserie, :cookie, :tart, :quiche, :sandwich, :pot_pie, :dry_goods, :other].sample
    description {Faker::Lorem.sentence(1)}
    weight { Faker::Number.decimal(l_digits = 0, r_digits = 3) }
    unit [:oz, :lb, :g, :kg].sample
    extra_amount { Faker::Number.decimal(l_digits = 0, r_digits = 3) }
    association :inclusion, factory: :recipe_inclusion
    association :motherdough, factory: :recipe_motherdough
  end
end
