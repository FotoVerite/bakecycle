class Route < ActiveRecord::Base
  belongs_to :bakery
  has_many :orders

  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery }
  validates :departure_time, presence: true
  validates :active, inclusion: [true, false]
  validates :bakery, presence: true

  def self.active
    where(active: true)
  end

  def formatted_time
    return unless departure_time
    departure_time.strftime('%I:%M %p')
  end
end
