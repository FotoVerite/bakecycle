FactoryGirl.define do
  factory :recipe_item do
    bakers_percentage { Faker::Number.between(1, 100) }
    association :inclusionable, factory: :ingredient

    factory :recipe_item_ingredient do
      association :inclusionable, factory: :ingredient
    end

    factory :recipe_item_recipe do
      association :inclusionable, factory: :recipe
    end
  end
end
