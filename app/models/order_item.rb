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

  def self.can_start_on_date(date)
    all.select { |order_item| order_item.can_start_on_date?(date) }
  end

  def set_quantity_zero_if_blank
    DAYS_OF_WEEK.each do |day|
      send(:"#{day}=", 0) unless send(day)
    end
  end

  def total_lead_days
    return 0 unless product.total_lead_days
    product.total_lead_days
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

  def can_start_on_date?(start_date)
    delivery_days = DAYS_OF_WEEK.select { |day| self[day] > 0 }
    delivery_days.include?(order_ready_day(start_date))
  end

  def order_ready_day(start_date)
    (start_date + product.total_lead_days.days).strftime('%A').downcase.to_sym
  end
end
