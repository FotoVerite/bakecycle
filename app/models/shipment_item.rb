class ShipmentItem < ActiveRecord::Base
  belongs_to :shipment
  belongs_to :product

  validates :product, :product_id, presence: true
  validates :product_name, presence: true
  validates :product_quantity, presence: true, numericality: true
  validates :price_per_item, presence: true, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: true

  before_validation :set_product_name

  def set_product_name
    self.product_name = product.name if product
  end
end
