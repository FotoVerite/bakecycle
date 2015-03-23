class RecipeRun
  attr_reader :date, :shipment_items

  def initialize(date, shipment_items)
    @date = date
    @shipment_items = shipment_items
  end

  def collection
    counts = group_by_id_and_count
    products = Product.where(id: counts.keys).order(:name)
    products.map do |product|
      count = counts[product.id]
      over_bake_qty = (count + (count * product.over_bake / 100.0)).ceil
      OpenStruct.new(
        product: product,
        count: count,
        over_bake: over_bake_qty,
        over_bake_percentage: product.over_bake)
    end
  end

  private

  def find_by_production_date
    @shipment_items.where(production_start: @date)
  end

  def group_by_id_and_count
    find_by_production_date.group(:product_id).sum(:product_quantity)
  end
end
