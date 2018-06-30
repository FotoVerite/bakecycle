class VendorPricingForm
  extend ActiveModel::Naming

  attr_accessor :ingredients

  def initialize(ingredients:, vendor:)
    @ingredients = ingredients
    @vendor = vendor
    serializable_hash
  end

  def serializable_hash
    hash = { ingredients: [] }
    @ingredients.each do |i|
      hash[:ingredients].push(
        id: i.id,
        name: i.name,
        ingredient_type: i.ingredient_type,
        cost: i.cost_by_vendor(@vendor),
        dirty: false,
        weight_unit: (i.weight_unit || "grams"),
        conversion: i.conversion,
        cost_over_time_vendor_id: @vendor.id,
        updated_at: i.pricing_updated_last_at(@vendor)
      )
    end
    hash[:filter] = []
    hash[:weightUnitOptions] = Ingredient::WEIGHT_UNITS
    hash
  end
end
