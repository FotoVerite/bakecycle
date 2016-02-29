class OrderFormSerializer < ActiveModel::Serializer
  has_one :order
  has_many :available_clients
  has_many :available_routes
  has_many :available_products
end
