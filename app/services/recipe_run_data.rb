class RecipeRunData
  delegate  :total_lead_days, :mix_size_with_unit, to: :recipe
  attr_reader :recipe, :products, :inclusions, :weight,
              :recipe_items, :date

  def initialize(recipe, date)
    @recipe = recipe
    @date = date
    @products = []
    @parent_recipe_map = {}
    @inclusions = []
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

  def mix_bowl_count
    return 1 unless recipe.mix_size_with_unit > Unitwise(0, :kg)
    (weight / recipe.mix_size_with_unit).to_f.ceil
  end

  def finished_date
    date + recipe.total_lead_days.days
  end

  def parent_recipes
    @parent_recipe_map.values
  end
end
