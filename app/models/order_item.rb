class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product

  before_validation :zero_if_blank

  DAYS_OF_WEEK = [
    :monday,
    :tuesday,
    :wednesday,
    :thursday,
    :friday,
    :saturday,
    :sunday
  ]

  validates :product, :product_id, presence: true
  validates(*DAYS_OF_WEEK, numericality: true)

  def days_of_week
    DAYS_OF_WEEK
  end

  def zero_if_blank
    days_of_week.each do |day|
      send(:"#{day}=", 0) unless send(day)
    end
  end

  def weekly_quantity
    qty = 0
    days_of_week.each do |day|
      qty += send(day) || 0
    end
    qty
  end
end
