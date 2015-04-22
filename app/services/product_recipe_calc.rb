class ProductRecipeCalc
  attr_reader :product, :quantity, :inclusion, :recipe
  def initialize(product, quantity)
    @product = product
    @quantity = quantity
    @inclusion = product.inclusion
    @recipe = product.motherdough
  end

  def product_info
    { product: product, quantity: quantity, weight: product_weight, dough_weight: dough_weight }
  end

  def inclusion_info
    return nil unless inclusion
    { product: product, recipe: inclusion, weight: inclusions_weight }
  end

  def dough_weight
    dough_percentage * percent_weight
  end

  private

  def product_weight
    (product.weight_with_unit * quantity).to_kg
  end

  def inclusions_weight
    inclusion_percentage * percent_weight
  end

  def percent_weight
    return product_weight if dough_percentage_zero? && inclusion_percentage_zero?
    product_weight / (dough_percentage + inclusion_percentage)
  end

  def dough_percentage_zero?
    dough_percentage == 0
  end

  def inclusion_percentage_zero?
    inclusion_percentage == 0
  end

  def inclusion_percentage
    return 0 unless inclusion
    inclusion.recipe_items.map(&:bakers_percentage).sum
  end

  def dough_percentage
    recipe.recipe_items.map(&:bakers_percentage).sum
  end
end
