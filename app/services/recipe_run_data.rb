class RecipeRunData
  attr_reader :recipe, :products, :inclusions, :weight

  def initialize(recipe)
    @recipe = recipe
    @products = []
    @inclusions = []
    @weight = Unitwise(0, :kg)
  end

  def add_product(product, quantity)
    calculator = ProductRecipeCalc.new(product, quantity)
    products.push(calculator.product_info)
    inclusions.push(calculator.inclusion_info) if product.inclusion
    @weight += calculator.dough_weight
  end
end
