class PriceVariantSerializer < ActiveModel::Serializer
  attributes :id, :price, :quantity, :errors, :client_id
end
