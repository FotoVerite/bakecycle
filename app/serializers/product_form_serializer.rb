class ProductFormSerializer < ActiveModel::Serializer
  has_one :product
  has_many :clients
end
