class RecipeCalc
  attr_reader :recipe, :weight

  def initialize(recipe, weight)
    @recipe = recipe
    @weight = weight
  end

  def ingredients_info
    recipe.recipe_items.map do |item|
      {
        parent_recipe: recipe,
        inclusionable: item.inclusionable,
        weight: weight_for(item),
        bakers_percentage: item.bakers_percentage,
        inclusionable_type: item.inclusionable_type
      }
    end
  end

  def deeply_nested_recipe_info
    recipes_info + recipes_info.map { |info|
      RecipeCalc.new(
        info[:inclusionable],
        info[:weight]
      ).deeply_nested_recipe_info
    }.flatten
  end

  private

  def recipes_info
    ingredients_info.select { |item| item[:inclusionable_type] == 'Recipe' }
  end

  def weight_for(item)
    weight / total_percentage * item.bakers_percentage
  end

  def total_percentage
    @_total_percentage ||= recipe.recipe_items.map(&:bakers_percentage).sum
  end
end
