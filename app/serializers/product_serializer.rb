class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :errors
  has_many :price_variants
end
