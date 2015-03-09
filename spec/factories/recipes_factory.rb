FactoryGirl.define do
  factory :recipe do
    recipe_type { Recipe.recipe_types.keys.sample }
    sequence(:name) { |n| "#{n}#{Faker::Lorem.word}" }
    mix_size 12
    mix_size_unit { Recipe.mix_size_units.keys.sample }
    lead_days 2
    bakery

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

    trait :with_ingredients do
      transient do
        ingredient_count 3
      end

      after(:build) do |recipe, evaluator|
        recipe.recipe_items = build_list(:recipe_item_ingredient, evaluator.ingredient_count, bakery: evaluator.bakery)
      end
    end
  end
end
