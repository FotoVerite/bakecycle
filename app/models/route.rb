class Route < ActiveRecord::Base
  has_many :orders
  has_many :shipments

  belongs_to :bakery

  validates :name, presence: true, length: { maximum: 150 }
  validates :departure_time, presence: true
  validates :active, inclusion: [true, false]
  validates :bakery, presence: true

  def formatted_time
    departure_time.strftime("%I:%M %p")
  end

  def active?
    active ? "Yes" : "No"
  end
end
