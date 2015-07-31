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

  scope :order_by_product_type_and_name, -> { joins(:product).order('products.product_type asc, products.name asc') }

  def self.group_and_order_by_product
    order_by_product_type_and_name.group_by { |order_item| order_item.product.product_type }
  end

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
  def self.production_date(start_date)
    # Returns order items considering active and temp orders. Start date + Lead
    # Time of each product on each order item
    sql = <<-SQL
      order_items.id in (
        SELECT
          item_id
        FROM (
          SELECT
            order_items.id item_id,
            orders.id order_id,
            orders.client_id client_id,
            orders.route_id route_id,
            (DATE :production_date + (INTERVAL '1 day' * order_items.total_lead_days)) ship_date
          FROM order_items
          INNER JOIN orders ON orders.id = order_items.order_id
          WHERE
            -- this section reduces the dataset by a bunch so we do less work with each item's total_lead_days
            DATE :production_date >= (orders.start_date - (INTERVAL '1 day' * (select COALESCE(max(total_lead_days), 1) from order_items)))
            AND (
              DATE :production_date <= orders.end_date
              OR orders.end_date IS NULL
            )

            -- find all order items that have active orders on the production_date + lead time
            AND DATE :production_date >= (orders.start_date - (INTERVAL '1 day' * order_items.total_lead_days))
            AND (
              DATE :production_date <= (orders.end_date - (INTERVAL '1 day' * order_items.total_lead_days))
              OR orders.end_date IS NULL
            )
        ) items_to_work
        WHERE
          -- reduce to order items that are active on their ship_date
          -- this step is why this query is so slow
          order_id in (
            SELECT id from (
              SELECT
                id,
                first_value(id) OVER (PARTITION BY client_id, route_id ORDER BY order_type DESC) active_order_id
              FROM orders check_orders
              WHERE
                start_date <= ship_date AND (end_date is null OR end_date >= ship_date)
                AND client_id = check_orders.client_id
            ) active_orders
            WHERE id = active_order_id
          )
      )
    SQL
    where(sql, production_date: start_date)
  end
  # rubocop:enable Metrics/MethodLength, Metrics/LineLength

  def set_quantity_zero_if_blank
    DAYS_OF_WEEK.each do |day|
      send(:"#{day}=", 0) unless send(day)
    end
  end

  def product_price
    product.price(total_quantity, order.client) if product && order
  end

  def total_quantity_price
    product_price * total_quantity if product_price
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
