class RecipeCalc
  attr_reader :recipe, :weight

  def initialize(recipe, weight)
    @recipe = recipe
    @weight = weight
  end

  def ingredients_info
    recipe.recipe_items.map do |item|
      {
        inclusionable: item.inclusionable,
        weight: weight_for(item),
        bakers_percentage: item.bakers_percentage,
        inclusionable_type: item.inclusionable_type
      }
    end
  end

  private

  def weight_for(item)
    weight / total_percentage * item.bakers_percentage
  end

  def total_percentage
    @_total_percentage ||= recipe.recipe_items.map(&:bakers_percentage).sum
  end
end
