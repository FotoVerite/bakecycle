# == Schema Information
#
# Table name: products
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  product_type    :integer          not null
#  weight          :decimal(, )      not null
#  unit            :integer          not null
#  description     :text
#  over_bake       :decimal(, )      default(0.0), not null
#  motherdough_id  :integer
#  inclusion_id    :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  base_price      :decimal(, )      not null
#  bakery_id       :integer          not null
#  sku             :string
#  legacy_id       :string
#  total_lead_days :integer          not null
#  batch_recipe    :boolean          default(FALSE)
#

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
