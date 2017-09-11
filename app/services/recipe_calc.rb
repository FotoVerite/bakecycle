class RecipeCalc
  attr_reader :recipe, :weight

  def initialize(recipe, weight)
    @recipe = recipe
    @weight = weight
  end

  def ingredients_info
    recipe.recipe_items.sort_by(&:sort_id).map do |item|
      {
        parent_recipe: recipe,
        inclusionable: item.inclusionable,
        weight: weight_for(item),
        cost: item.inclusionable.cost_per_gram * weight_for(item).to_f, 
        bakers_percentage: item.bakers_percentage,
        inclusionable_type: item.inclusionable_type,
        sort_id: item.sort_id
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
