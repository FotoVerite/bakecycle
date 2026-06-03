class CostingForm
  extend ActiveModel::Naming
  include ActiveModel::Serialization

  attr_accessor :ingredients
  attr_reader :item_finder

  def initialize(ingredients:, user:)
    @ingredients = IngredientDecorator.decorate_collection ingredients
    @item_finder = ItemFinder.new(user)

    @available_vendors = ItemFinder.new(user)
  end

  def available_vendors
    item_finder.vendors.order(:name)
  end

  def serializable_hash
    hash = CostingFormSerializer.new(self).serializable_hash
    hash[:ingredients].map do |i|
      i["dirty"] = false
      i["weight_unit"] = "grams" unless i["weight_unit"]
      i["conversion"] = 1.00 if i["conversion"].to_f.zero?
    end
    hash[:filter] = []
    hash[:weightUnitOptions] = Ingredient::WEIGHT_UNITS
    hash.transform_keys { |k| k.to_s.camelize(:lower) }
  end
end
