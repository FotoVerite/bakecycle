FactoryGirl.define do
  factory :recipe do
    name { generate(:recipe_name) }
    recipe_type { Recipe.recipe_types.keys.sample }
    mix_size 12
    mix_size_unit { Recipe.mix_size_units.keys.sample }
    lead_days 2
    bakery

    factory :recipe_motherdough do
      recipe_type :dough
      lead_days 2
    end

    factory :recipe_preferment do
      recipe_type :preferment
      lead_days 1
    end

    factory :recipe_inclusion do
      recipe_type :inclusion
      lead_days 0
    end

    trait :with_ingredients do
      lead_days 0
      transient do
        ingredient_count 3
      end

      after(:build) do |recipe, evaluator|
        recipe.recipe_items += build_list(
          :recipe_item_ingredient,
          evaluator.ingredient_count,
          bakery: evaluator.bakery
        )
      end
    end

    trait :with_nested_recipes do
      transient do
        recipe_count 3
        recipe_lead_days 2
      end

      after(:build) do |recipe, evaluator|
        recipe.recipe_items += build_list(
          :recipe_item_recipe,
          evaluator.recipe_count,
          recipe_lead_days: evaluator.recipe_lead_days,
          bakery: evaluator.bakery
        )
      end
    end
  end

  sequence :recipe_name do |n|
    recipes = [
      "Baguette",
      "Baguette Poolish",
      "Black sesame petit pain",
      "Brioche",
      "Brioche Cocoa Nib",
      "Brioche Orange Blossom",
      "Brioche Traditional",
      "Broa",
      "Broa Biga",
      "Campagne",
      "Challah",
      "Challah Milk Poolish",
      "Chive Lobster Roll",
      "Chive Pain au Lait",
      "Ciabatta"
    ]
    "#{recipes.sample} ##{n}"
  end
end
