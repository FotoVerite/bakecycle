class RecipeRunData
  attr_reader :recipe, :products, :inclusions, :weight, :recipe_items

  def initialize(recipe)
    @recipe = recipe
    @products = []
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

  def weight=(weight)
    @weight = weight
    calculate_recipe_item_weight
  end

  def calculate_recipe_item_weight
    @recipe_items = RecipeCalc.new(recipe, @weight).ingredients_info
  end

  def ingredients
    recipe_items.select { |item| item[:inclusionable_type] == 'Ingredient' }
  end

  def nested_recipes
    recipe_items.select { |item| item[:inclusionable_type] == 'Recipe' }
  end
end
