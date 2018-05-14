class VendorPricingFormSerializer < ActiveModel::Serializer
  has_many :ingredients
  class IngredientSerializer < ActiveModel::Serializer
    attributes :id, :name, :ingredient_type, :current_amount, :vendor_id, :cost
  end
end
