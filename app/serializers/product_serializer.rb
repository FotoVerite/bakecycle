class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :errors, :base_price, :total_lead_days
  has_many :price_variants

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
