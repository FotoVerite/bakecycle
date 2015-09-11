class ProductDecorator < Draper::Decorator
  delegate_all

  def type
    product_type.humanize(capitalize: false).titleize
  end

  def product_types_select
    object.class.product_types.keys.map { |key| [key.humanize(capitalize: false), key] }
  end

  def units_select
    object.class.units.keys.map { |key| [key.humanize(capitalize: false), key] }
  end

  def truncated_description
    return description.truncate(30) if description
    nil
  end

  def inclusions
    h.item_finder.recipes.inclusions.order(:name)
  end

  def motherdoughs
    h.item_finder.recipes.motherdoughs.order(:name)
  end

  def sku_display
    return "N/A" unless sku.present?
    sku
  end

  def serializable_hash
    ProductSerializer.new(object).serializable_hash
  end
end
