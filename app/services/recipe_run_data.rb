class RecipeRunData
  delegate  :total_lead_days, :mix_size_with_unit, to: :recipe
  attr_reader :recipe, :products, :inclusions, :weight,
              :recipe_items, :parent_recipes, :date

  def initialize(recipe, date)
    @recipe = recipe
    @date = date
    @products = []
    @parent_recipes = []
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

  def add_parent_recipe(parent_recipe, weight)
    self.weight += weight
    detected_parent_recipe = detect_parent_recipe(parent_recipe)
    parent_recipe_item = detected_parent_recipe || new_parent_recipe_item(parent_recipe)
    parent_recipes << parent_recipe_item unless detected_parent_recipe
    parent_recipe_item[:weight] += weight
  end

  def deeply_nested_recipe_info
    RecipeCalc.new(recipe, @weight).deeply_nested_recipe_info
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

  def mix_bowl_count
    return unless recipe.mix_size_with_unit > Unitwise(0, :kg)
    (weight / recipe.mix_size_with_unit).to_f.ceil
  end

  def finished_date
    date + recipe.total_lead_days.days
  end

  private

  def new_parent_recipe_item(parent_recipe)
    { parent_recipe: parent_recipe, weight: Unitwise(0, :kg) }
  end

  def detect_parent_recipe(parent_recipe)
    parent_recipes.detect { |data| data[:parent_recipe] == parent_recipe }
  end
end
