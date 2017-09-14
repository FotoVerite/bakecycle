class CostingCalc
  attr_reader :items, :recipe, :total_cost, :weight

  def initialize(recipe, weight)
    @recipe = recipe
    @weight = weight
    @total_cost = 0
    @items = cost_recipe
  end

  def cost_recipe
    recipe.recipe_items.sort_by(&:sort_id).map do |item|
       hash = {
        name: item.inclusionable.name,
        weight: weight_for(item),
        cost: item.inclusionable.cost_per_gram * weight_for(item).to_f, 
        type: item.inclusionable_type,
        sort_id: item.sort_id
      }
      @total_cost += item.inclusionable.cost_per_gram * weight_for(item).to_f
      if item.inclusionable_type == 'Recipe'
        calculator  =  CostingCalc.new(item.inclusionable, hash[:weight])
        hash[:ingredients] = calculator.items
        hash[:cost] = calculator.total_cost
        @total_cost += calculator.total_cost
      end
      hash
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
