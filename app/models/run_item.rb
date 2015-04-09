class RunItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :production_run

  has_many :shipment_items, through: :production_run
  validates :product, presence: true, uniqueness: { scope: :production_run_id, message: '- remove duplicate products' }
  validates :overbake_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :order_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :initialize_quantities, on: :create
  before_validation :update_total_quantity

  delegate :over_bake, to: :product

  def initialize_quantities
    RunItemQuantifier.new(self).set
  end

  def update_total_quantity
    self.total_quantity = overbake_quantity + order_quantity if overbake_quantity
  end
end
