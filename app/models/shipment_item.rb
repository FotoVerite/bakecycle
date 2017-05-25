# == Schema Information
#
# Table name: shipment_items
#
#  id                      :integer          not null, primary key
#  shipment_id             :integer
#  product_id              :integer
#  product_name            :string
#  product_quantity        :integer          default(0), not null
#  product_price           :decimal(, )      default(0.0), not null
#  product_sku             :string
#  production_start        :date             not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  production_run_id       :integer
#  product_product_type    :string           not null
#  product_total_lead_days :integer          not null
#

class ShipmentItem < ActiveRecord::Base
  include Denormalization
  belongs_to :shipment
  belongs_to :production_run
  belongs_to :product

  validates :product_quantity, presence: true, numericality: true
  validates :product_price, presence: true, numericality: true
  validates :product_id, presence: true
  validates :product_name, presence: true
  validates :product_product_type, presence: true
  validates :product_total_lead_days, presence: true

  denormalize :product, [
    :id, :name, :sku, :product_type, :total_lead_days
  ]

  before_validation :set_product_quantity_and_price
  before_save :set_production_start

  delegate :after_kickoff_time?, :before_kickoff_time?, to: :shipment

  def self.order_by_product_type_and_name
    order("product_product_type asc, product_name asc")
  end

  def self.earliest_production_date
    all.minimum(:production_start)
  end

  def price
    product_price * product_quantity
  end

  def product_duration
    production_start..production_start + product_total_lead_days.days
  end

  def in_production?
    return false if production_start == Time.zone.today && !after_kickoff_time?
    product_duration.include?(Time.zone.today)
  end

  def after_production?
    production_start + product_total_lead_days.days < Time.zone.today
  end

  def set_production_start
    return unless shipment && shipment.date
    self.production_start = shipment.date - product_total_lead_days
  end

  def set_product_quantity_and_price
    self.product_quantity ||= 0
    self.product_price ||= 0
  end
end
