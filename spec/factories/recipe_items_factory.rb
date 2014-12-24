require "faker"

FactoryGirl.define do
  factory :recipe_item_ingredient, class: "RecipeItem" do
    association :inclusionable, factory: :ingredient
    recipe
    bakers_percentage 50.0
  end

  factory :recipe_item_recipe, class: "RecipeItem" do
    association :inclusionable, factory: :recipe
    recipe
    bakers_percentage 65.0
  end
end
