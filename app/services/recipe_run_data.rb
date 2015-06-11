class RecipeRunData
  delegate  :total_lead_days, :mix_size_with_unit, to: :recipe
  attr_reader :recipe, :products, :inclusions, :inclusions_info, :weight,
              :recipe_items, :date

  def initialize(recipe, date)
    @recipe = recipe
    @date = date
    @products = []
    @parent_recipe_map = {}
    @inclusions = []
    @inclusions_info = []
    @recipe_items = []
    self.weight = Unitwise(0, :kg)
  end

  def add_product(product, quantity)
    calculator = ProductRecipeCalc.new(product, quantity)
    products.push(calculator.product_info)
    inclusions.push(calculator.inclusion_info) if product.inclusion
    self.weight += calculator.dough_weight
  end

  def update_parent_recipe(parent_recipe, weight)
    @parent_recipe_map[parent_recipe] ||= { parent_recipe: parent_recipe, weight: Unitwise(0, :kg) }
    parent_recipe_info = @parent_recipe_map[parent_recipe]

    self.weight -= parent_recipe_info[:weight]
    self.weight += weight
    parent_recipe_info[:weight] = weight
  end

  def weight=(weight)
    @weight = weight
    @recipe_items = RecipeCalc.new(recipe, @weight).ingredients_info
  end

  def ingredients
    recipe_items.select { |item| item[:inclusionable_type] == 'Ingredient' }
  end

  def nested_recipes
    recipe_items.select { |item| item[:inclusionable_type] == 'Recipe' }
  end

  attr_writer :mix_bowl_count
  def mix_bowl_count
    return @mix_bowl_count if @mix_bowl_count
    return 1 unless recipe.mix_size_with_unit > Unitwise(0, :kg)
    (weight / recipe.mix_size_with_unit).to_f.ceil
  end

  def finished_date
    date + recipe.total_lead_days.days
  end

  def parent_recipes
    @parent_recipe_map.values
  end

  def bowl_ingredient_weight(ingredient_info)
    return Unitwise(0, :kg) if ingredient_info[:weight] == Unitwise(0, :kg)
    ingredient_info[:weight] / mix_bowl_count
  end

  def sorted_parent_recipes
    parent_recipes.sort_by { |recipe| recipe[:parent_recipe][:name].downcase }
  end

  def total_bowl_weight
    return Unitwise(0, :kg) if weight == Unitwise(0, :kg)
    weight / mix_bowl_count
  end

  def sorted_recipe_run_date_products
    products.sort_by { |product| [product_without_inclusion(product), product[:product].name.downcase] }
  end

  def inclusion_for_product(product)
    inclusions.detect { |i| i[:product] == product[:product] }
  end

  def add_recipe_inclusions_info
    recipe_inclusion_groups.each do |inclusion, products|
      total_inclusion_weight = total_weight(products, :inclusion_weight)
      total_dough_weight = total_weight(products, :dough_weight)
      inclusions_info << {
        inclusion: inclusion,
        total_inclusion_weight: total_inclusion_weight,
        dough: recipe,
        total_dough_weight: total_dough_weight,
        total_product_weight: total_dough_weight + total_inclusion_weight,
        ingredients: inclusion_ingredients(inclusion, total_inclusion_weight)
      }
    end
  end

  def inclusion_ingredients(inclusion, total_inclusion_weight)
    inclusion.recipe_items.map do |recipe_item|
      next unless recipe_item.inclusionable_type == 'Ingredient'
      {
        ingredient: recipe_item.inclusionable,
        weight: weight_for(inclusion, recipe_item.bakers_percentage, total_inclusion_weight)
      }
    end.compact
  end

  def recipe_inclusion_groups
    inclusions.group_by { |inclusion| inclusion[:recipe] }
  end

  def products_with_inclusion
    sorted_recipe_run_date_products.select { |product| product[:product].inclusion }
  end

  private

  def product_without_inclusion(product)
    product[:product].inclusion ? 1 : 0
  end

  def total_weight(products, weight_type)
    products.reduce(Unitwise(0, :kg)) { |sum, inclusion| sum + inclusion[weight_type] }
  end

  def weight_for(inclusion, bakers_percentage, total_inclusion_weight)
    total_inclusion_weight / inclusion.total_bakers_percentage * bakers_percentage
  end
end
