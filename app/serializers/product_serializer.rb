class ProductSerializer < ActiveModel::Serializer
  attributes :clients, :id, :name, :errors, :base_price
  has_many :price_variants

  def clients
    object.bakery.clients.order(name: :asc)
  end

  def price_variants
    object.price_variants.sort_by do |price_variant|
      [
        price_variant.persisted? ? 0 : 1,
        price_variant.client_name,
        price_variant.quantity || 0
      ]
    end
  end
end
