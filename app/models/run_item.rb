class RunItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :production_run

  has_many :shipment_items, through: :production_run

  validates :product, presence: true
  validates :total_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :overbake_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :order_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :initialize_quantities

  def initialize_quantities
    RunItemQuantifier.new(self).set
  end
end
