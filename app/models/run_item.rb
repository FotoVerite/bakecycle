class RunItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :production_run

  validates :product, presence: true, uniqueness: {
    scope: :production_run_id,
    message: 'Cannot add same product more than once'
  }
  validates :overbake_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :order_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :zero_fields_if_blank
  before_validation :update_total_quantity

  delegate :over_bake, to: :product

  def self.order_by_product_name
    all.includes(:product).order('products.name asc')
  end

  def self.order_by_product_type_and_name
    all.includes(:product).order('products.product_type asc, products.name asc')
  end

  def from_shipment?
    order_quantity > 0 if order_quantity
  end

  def shipment_items=(shipment_items)
    RunItemQuantifier.new(self, shipment_items).set
  end

  def zero_fields_if_blank
    self.overbake_quantity ||= 0
    self.order_quantity ||= 0
  end

  def update_total_quantity
    self.total_quantity = overbake_quantity + order_quantity
  end
end
