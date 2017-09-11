class CostingData
  attr_reader :bakery, :recipes_collection, :product, :weight
  def initialize(product)
    @product = product
    @bakery = product.bakery
    @recipes_collection = CostingRecipeCollection.new
    processes_product
  end

  def processes_product
    add_to_recipe_run_data(@product, 1)
  end

  def recipes
    @_recipes ||= recipes_collection.sort_by do |recipe|
      [recipes_without_products(recipe), recipe.recipe.name.downcase]
    end
  end

  def recipes_without_preferments
    recipes.reject do |recipe|
      recipe.recipe.recipe_type == "preferment"
    end
  end

  def preferments
    recipes.select do |recipe|
      recipe.recipe.recipe_type == "preferment"
    end
  end

  def total_items_cost
    @recipes_collection.sum {|c| c.total_items_cost}
  end

  private

  def recipes_without_products(recipe)
    recipe.products.any? ? 0 : 1
  end

  def add_to_recipe_run_data(product, quantity)
    motherdough = product.motherdough
    return unless motherdough
    recipe_data = recipes_collection.find_or_create(motherdough)
    recipe_data.add_product(product, quantity)
    update_nested_recipes(recipe_data)
  end

  def update_nested_recipes(recipe_data)
    recipe_data.nested_recipes.each do |nested_info|
      nested_data = recipes_collection.find_or_create(nested_info[:inclusionable])
      update_nested_recipes(nested_data)
    end
  end

end

class CostingRecipeCollection < Set
  def find_or_create(recipe)
    recipe_data = detect { |data| data.recipe == recipe } || CostingRecipeData.new(recipe)
    add(recipe_data)
    recipe_data
  end
end

