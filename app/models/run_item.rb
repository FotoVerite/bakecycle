# == Schema Information
#
# Table name: run_items
#
#  id                :integer          not null, primary key
#  production_run_id :integer          not null
#  product_id        :integer          not null
#  total_quantity    :integer
#  order_quantity    :integer
#  overbake_quantity :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class RunItem < ActiveRecord::Base
  extend OrderByProduct

  belongs_to :product
  belongs_to :production_run

  validates :order_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :overbake_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :product, presence: true, uniqueness: {
    scope: :production_run_id,
    message: "Cannot add the same product more than once"
  }

  before_validation :zero_fields_if_blank
  before_validation :update_total_quantity

  delegate :name, :over_bake, :total_lead_days, to: :product, prefix: true

  def from_shipment?
    order_quantity > 0 if order_quantity
  end

  def shipment_items=(shipment_items)
    RunItemQuantifier.new(self, shipment_items).set
  end

  def zero_fields_if_blank
    self.overbake_quantity ||= 0
    self.order_quantity ||= 0
    # NB fix if you are removing all items from a production run
    self.order_quantity = 0 if order_quantity < 0
  end

  def update_total_quantity
    self.total_quantity = overbake_quantity + order_quantity
  end

  def product_type
    product.product_type.humanize(capitalize: false).titleize
  end
end
