FactoryGirl.define do
  factory :recipe do
    recipe_type { Recipe.recipe_types.except(:inclusion).keys.sample }
    sequence(:name) { |n| "#{n}#{Faker::Lorem.word}" }
    mix_size 12
    mix_size_unit { Recipe.mix_size_units.keys.sample }
    lead_days 2
    bakery

    factory :recipe_motherdough do
      recipe_type :dough
    end

    factory :recipe_preferment do
      recipe_type :preferment
    end

    factory :recipe_inclusion do
      recipe_type :inclusion
      lead_days 0
    end

    factory :recipe_ingredient do
      recipe_type :ingredient
    end

    trait :with_ingredients do
      lead_days 0
      transient do
        ingredient_count 3
      end

      after(:build) do |recipe, evaluator|
        recipe.recipe_items = build_list(:recipe_item_ingredient, evaluator.ingredient_count, bakery: evaluator.bakery)
      end
    end

    trait :with_nested_recipe do
      transient do
        recipe_lead_days 2
      end

      after(:build) do |recipe, evaluator|
        recipe.recipe_items = [build(:recipe_item_recipe, recipe_lead_days: evaluator.recipe_lead_days)]
      end
    end
  end
end
