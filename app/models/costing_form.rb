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
    hash[:ingredients].map { |i| i["dirty"] = false }
    hash[:filter] = []
    hash
  end
end
