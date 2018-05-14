class CostingRecipeData
  attr_reader :recipe, :product, :product_calculations, :inclusion, :weight,
              :motherdough, :total_cost

  def initialize(product, quantity)
    calculator = ProductRecipeCalc.new(product, quantity)
    @product_calculations = calculator.product_info
    @weight = calculator.product_weight
    @motherdough = CostingCalc.new(product.motherdough, calculator.dough_weight)
    @inclusion = CostingCalc.new(product.inclusion, calculator.inclusion_weight) if product.inclusion
    @total_cost = @motherdough.total_cost + inclusion.try(:total_cost).to_f
  end
end
