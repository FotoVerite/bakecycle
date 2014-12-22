class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product

  validates :product, presence: true
  validates :monday,
            :tuesday,
            :wednesday,
            :thursday,
            :friday,
            :saturday,
            :sunday,
            presence: true, numericality: true

end
