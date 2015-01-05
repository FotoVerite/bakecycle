require 'faker'

FactoryGirl.define do
  factory :recipe do
    sequence(:name) { |n| "#{n}#{Faker::Lorem.word}" }
    note { Faker::Lorem.sentence(1) }
    mix_size 12
    mix_size_unit [:oz, :lb, :g, :kg].sample
    lead_days 2
    recipe_type [:dough, :pre_ferment, :inclusion, :ingredient].sample

    factory :recipe_motherdough do
      recipe_type :dough
    end

    factory :recipe_preferment do
      recipe_type :pre_ferment
    end

    factory :recipe_inclusion do
      recipe_type :inclusion
    end

    factory :recipe_ingredient do
      recipe_type :ingredient
    end
  end
end