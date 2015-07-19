class Route < ActiveRecord::Base
  extend AlphabeticalOrder

  belongs_to :bakery
  has_many :orders

  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery }
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
