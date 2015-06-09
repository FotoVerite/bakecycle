class OrderItem < ActiveRecord::Base
  extend OrderByProduct

  belongs_to :product
  belongs_to :order

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

  before_save :set_total_lead_days, if: :update_total_lead_days?
  after_touch :update_total_lead_days

  def update_total_lead_days?
    new_record? || product_id_changed?
  end

  def update_total_lead_days
    update_columns(total_lead_days: set_total_lead_days)
  end

  def set_total_lead_days
    self.total_lead_days = product.total_lead_days
  end

  def production_start_on?(start_date)
    ready_date =  start_date + total_lead_days.days
    quantity(ready_date) > 0
  end

  # rubocop:disable Metrics/MethodLength, Metrics/LineLength
  def self.production_start_on?(start_date)
    sql = <<-SQL
      order_items.id in (
        SELECT item_id
        FROM (
          SELECT
            order_items.id item_id,
            orders.id order_id,
            first_value(orders.id) OVER (PARTITION BY client_id, route_id ORDER BY order_type DESC) active_order_id
          FROM order_items
          INNER JOIN orders ON orders.id = order_items.order_id
          WHERE
            -- this section reduces the dataset by a bunch so we do less work with each item's total_lead_days
            DATE :production_start_date >= (orders.start_date - (INTERVAL '1 day' * (select COALESCE(max(total_lead_days), 1) from order_items)))
            AND (
              DATE :production_start_date <= orders.end_date
              OR orders.end_date IS NULL
            )

            -- find all order items that have active orders on the production_start_date + lead time
            AND DATE :production_start_date >= (orders.start_date - (INTERVAL '1 day' * order_items.total_lead_days))
            AND (
              DATE :production_start_date <= (orders.end_date - (INTERVAL '1 day' * order_items.total_lead_days))
              OR orders.end_date IS NULL
            )
            ORDER BY
              client_id,
              route_id,
              order_type,
              order_id
        ) active_items
        WHERE active_items.order_id = active_items.active_order_id
      )
    SQL
    where(sql, production_start_date: start_date)
  end
  # rubocop:enable Metrics/MethodLength, Metrics/LineLength

  def set_quantity_zero_if_blank
    DAYS_OF_WEEK.each do |day|
      send(:"#{day}=", 0) unless send(day)
    end
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
