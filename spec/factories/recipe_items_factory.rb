FactoryGirl.define do
  factory :recipe_item, aliases: [:recipe_item_ingredient] do
    transient do
      bakery { |t| t.association(:bakery) }
    end

    bakers_percentage { Faker::Number.between(1, 100) }
    inclusionable { |t| t.association(:ingredient, bakery: bakery) }

    factory :recipe_item_recipe do
      transient do
        recipe_lead_days 2
      end
      inclusionable { |t| t.association(:recipe, bakery: bakery, lead_days: recipe_lead_days) }
    end
  end
end
