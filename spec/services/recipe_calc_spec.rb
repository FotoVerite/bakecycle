require "rails_helper"

describe RecipeCalc do
  describe "#ingredients_info" do
    it "returns info for recipe items" do
      ingredient = Ingredient.new
      included_recipe = Recipe.new
      recipe_items = [
        RecipeItem.new(
          bakers_percentage: 100,
          inclusionable: ingredient,
          sort_id: 1
        ),
        RecipeItem.new(
          bakers_percentage: 50,
          inclusionable: included_recipe,
          sort_id: 2
        )
      ]
      recipe = double(Recipe, recipe_items: recipe_items)
      weight = Unitwise(15, :kg)
      recipe_calc = RecipeCalc.new(recipe, weight)
      recipe_item_info = [
        {
          parent_recipe: recipe,
          inclusionable: ingredient,
          weight: Unitwise(10, :kg),
          bakers_percentage: BigDecimal.new(100),
          inclusionable_type: "Ingredient",
          sort_id: 1
        },
        {
          parent_recipe: recipe,
          inclusionable: included_recipe,
          weight: Unitwise(5, :kg),
          bakers_percentage: BigDecimal.new(50),
          inclusionable_type: "Recipe",
          sort_id: 2
        }
      ]
      expect(recipe_calc.ingredients_info).to eq(recipe_item_info)
    end
  end
end
