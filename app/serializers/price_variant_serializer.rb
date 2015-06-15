class PriceVariantSerializer < ActiveModel::Serializer
  attributes :id, :price, :quantity, :errors
end
