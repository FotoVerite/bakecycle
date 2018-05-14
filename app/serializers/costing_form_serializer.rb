class CostingFormSerializer < ActiveModel::Serializer
  has_many :ingredients
  has_many :available_vendors
end
