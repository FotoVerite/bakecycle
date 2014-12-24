class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product

  before_validation :zero_if_blank

  validates :product, presence: true
  validates :monday,
            :tuesday,
            :wednesday,
            :thursday,
            :friday,
            :saturday,
            :sunday,
            numericality: true

  def zero_if_blank
    days_of_week = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
    days_of_week.each do |day|
      send(:"#{day}=", 0) unless send(day)
    end
  end
end
