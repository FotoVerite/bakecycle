class ShipmentItem < ActiveRecord::Base
  belongs_to :shipment
  belongs_to :production_run

  validates :product_id, presence: true
  validates :product_name, presence: true
  validates :product_quantity, presence: true, numericality: true
  validates :product_price, presence: true, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: true

  before_validation :set_product_data
  before_save :set_production_start

  scope :for_product, ->(product) { where(product_id: product.id) }

  def self.earliest_production_date
    all.minimum(:production_start)
  end

  def self.quantities_sum
    all.sum(:product_quantity)
  end

  def price
    product_price * product_quantity
  end

  def set_product_data
    self.product = Product.find(product_id) if product_id
  end

  def set_production_start
    return nil unless product_id
    product = Product.find(product_id)
    self.production_start = shipment.date - product.total_lead_days
  end

  def product=(product)
    fields = [
      :id, :name, :sku
    ]

    fields.each do |field|
      assign_method = "product_#{field}=".to_sym
      send(assign_method, product.send(field))
    end
  end
end
