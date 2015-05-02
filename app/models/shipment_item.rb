class ShipmentItem < ActiveRecord::Base
  include Denormalization
  belongs_to :shipment
  belongs_to :production_run

  validates :product_quantity, presence: true, numericality: true
  validates :product_price, presence: true, numericality: true
  validates :product_id, presence: true
  validates :product_name, presence: true
  validates :product_product_type, presence: true
  validates :product_total_lead_days, presence: true

  denormalize :product, [
    :id, :name, :sku, :product_type, :total_lead_days
  ]

  before_save :set_production_start

  def self.earliest_production_date
    all.minimum(:production_start)
  end

  def price
    product_price * product_quantity
  end

  def set_production_start
    return unless shipment && shipment.date
    self.production_start = shipment.date - product_total_lead_days
  end
end
