class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product

  before_validation :set_quantity_zero_if_blank

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

  def set_quantity_zero_if_blank
    DAYS_OF_WEEK.each do |day|
      send(:"#{day}=", 0) unless send(day)
    end
  end

  def lead_time
    return 0 unless product.lead_time
    product.lead_time
  end

  def product_price
    product.price(total_quantity) if product
  end

  def total_quantity_price
    product_price * total_quantity if product
  end

  def total_quantity
    DAYS_OF_WEEK.reduce(0) do |sum, day|
      sum + (send(day) || 0)
    end
  end

  def quantity(date)
    day = date.strftime('%A').downcase.to_sym
    send(day) || 0
  end

  def daily_subtotal(date)
    quantity(date) * product.price(total_quantity)
  end
end
