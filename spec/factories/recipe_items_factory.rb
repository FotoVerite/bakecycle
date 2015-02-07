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
    end

    inclusionable { build(:recipe, bakery: bakery) }
  end
end
