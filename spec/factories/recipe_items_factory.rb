FactoryGirl.define do
  factory :recipe_item_ingredient, class: RecipeItem do
    bakers_percentage { Faker::Number.between(1, 100) }
    transient do
      bakery { build(:bakery) }
    end

    after(:build) do |recipe_item, evaluator|
      recipe_item.inclusionable = build(:ingredient, bakery: evaluator.bakery)
    end
  end

  factory :recipe_item_recipe, class: RecipeItem do
    bakers_percentage { Faker::Number.between(1, 100) }
    transient do
      bakery { build(:bakery) }
    end

    after(:build) do |recipe_item, evaluator|
      recipe_item.inclusionable = build(:recipe, bakery: evaluator.bakery)
    end
  end
end
