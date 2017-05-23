class ProductRecipeCalc
  attr_reader :product, :quantity, :inclusion, :recipe
  def initialize(product, quantity)
    @product = product
    @quantity = quantity
    @inclusion = product.inclusion
    @recipe = product.motherdough
  end

  def product_info
    {
      dough_weight: dough_weight,
      inclusion: inclusion.present?,
      product: product,
      quantity: quantity,
      weight: product_weight
    }
  end

  def inclusion_info
    return nil unless inclusion
    {
      product: product,
      recipe: inclusion,
      inclusion_weight: inclusion_weight,
      dough_weight: dough_weight,
      product_weight: product_weight
    }
  end

  def dough_weight
    ((100 - inclusion_percentage)/100) * product_weight
  end

  private

  def product_weight
    (product.weight_with_unit * quantity).to_kg
  end

  def inclusion_weight
    ((inclusion_percentage/100) * product_weight)
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
    inclusion.total_bakers_percentage
  end

  def dough_percentage
    recipe.total_bakers_percentage
  end
end
