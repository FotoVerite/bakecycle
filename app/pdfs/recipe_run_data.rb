class RecipeRunData
  attr_reader :recipe, :products, :inclusions

  def initialize(recipe)
    @recipe = recipe
    @products = []
    @inclusions = Set.new
  end

  def run_data(product, quantity)
    add_product(product, quantity)
    add_inclusion(product.inclusion) if product.inclusion
  end

  def add_product(product, quantity)
    products.push(product: product, quantity: quantity)
  end

  def add_inclusion(inclusion)
    inclusions.add(inclusion)
  end
end
