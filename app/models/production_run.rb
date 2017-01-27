# == Schema Information
#
# Table name: production_runs
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  date       :date             not null
#  bakery_id  :integer          not null
#

class ProductionRun < ActiveRecord::Base
  belongs_to :bakery
  has_many :shipment_items
  has_many :run_items, dependent: :destroy

  accepts_nested_attributes_for(
    :run_items,
    allow_destroy: true,
    reject_if: proc { |attributes| attributes["product_id"].blank? }
  )

  def self.policy_class
    ProductionPolicy
  end

  def self.for_date(date)
    where(date: date)
  end

  def save(*args)
    super
  rescue ActiveRecord::RecordNotUnique
    errors[:base] << "Cannot add the same product more than once"
    false
  end
end
