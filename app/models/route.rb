# == Schema Information
#
# Table name: routes
#
#  id             :integer          not null, primary key
#  name           :string
#  notes          :text
#  active         :boolean          not null
#  departure_time :time             not null
#  bakery_id      :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  legacy_id      :integer
#

class Route < ApplicationRecord
  extend AlphabeticalOrder

  belongs_to :bakery
  has_many :orders

  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery_id }
  validates :departure_time, presence: true
  validates :active, inclusion: [true, false]
  validates :bakery, presence: true

  before_destroy :check_for_orders

  def self.policy_class
    ShippingPolicy
  end

  def self.active
    where(active: true)
  end

  private

  def check_for_orders
    return unless orders.any?
    errors.add(:base, I18n.t(:route_in_use, count: orders.count))
    false
  end
end
