FactoryGirl.define do
  factory :recipe_item_ingredient, class: RecipeItem do
    bakers_percentage { Faker::Number.between(1, 100) }
    transient do
      bakery { build(:bakery) }
    end

    inclusionable { build(:ingredient, bakery: bakery) }
  end

  factory :recipe_item_recipe, class: RecipeItem do
    bakers_percentage { Faker::Number.between(1, 100) }
    transient do
      bakery { build(:bakery) }
      recipe_lead_days 2
    end

    after(:build) do |recipe_item, evaluator|
      recipe_item.inclusionable ||=  build(:recipe, bakery: evaluator.bakery, lead_days: evaluator.recipe_lead_days)
    end
  end
end
