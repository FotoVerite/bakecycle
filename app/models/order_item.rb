# == Schema Information
#
# Table name: order_items
#
#  id              :integer          not null, primary key
#  order_id        :integer          not null
#  product_id      :integer          not null
#  monday          :integer          not null
#  tuesday         :integer          not null
#  wednesday       :integer          not null
#  thursday        :integer          not null
#  friday          :integer          not null
#  saturday        :integer          not null
#  sunday          :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  total_lead_days :integer          not null
#  removed         :integer          default(0)
#

class OrderItem < ApplicationRecord
  has_paper_trail
  extend OrderByProduct

  belongs_to :product
  belongs_to :order

  before_validation :set_quantity_zero_if_blank

  DAYS_OF_WEEK = %i[
    monday
    tuesday
    wednesday
    thursday
    friday
    saturday
    sunday
  ].freeze
  validates :product, :product_id, presence: true
  validates(*DAYS_OF_WEEK, numericality: true)

  before_save :set_total_lead_days, if: :update_total_lead_days?
  after_touch :update_total_lead_days
  after_commit :touch_order, on: %i[create update destroy]

  scope :order_by_product_type_and_name, -> { joins(:product).order("products.product_type asc, products.name asc") }

  def self.group_and_order_by_product
    order_by_product_type_and_name.group_by { |order_item| order_item.product.product_type }
  end

  # rubocop:disable Metrics/MethodLength
  # Returns order items that need to start production for a date using
  # their lead time date.
  # Orders will be active for a ship date to return a list of order items.
  def self.production_date(start_date)
    sql = <<-SQL.strip_heredoc
            order_items.id in(
              WITH items_to_work AS (
                SELECT
                  orders.order_type order_type,
                  order_items.id item_id,
                  orders.id order_id,
                  orders.client_id client_id,
                  orders.route_id route_id,
                  (DATE :production_date + order_items.total_lead_days) ship_date
                FROM order_items
                INNER JOIN orders ON orders.id = order_items.order_id
                WHERE
                  -- this section reduces the dataset by a bunch so we do less work with each item's total_lead_days
                  DATE :production_date >= (orders.start_date - (SELECT COALESCE(max(total_lead_days), 1) FROM order_items))
                  AND (
                    DATE :production_date <= orders.end_date
                    OR orders.end_date IS NULL
                  )
                  -- find all order items that have active orders on the production_date + lead time
                  AND DATE :production_date >= (orders.start_date::date - order_items.total_lead_days)
                  AND (
                    DATE :production_date <= (orders.end_date::date - order_items.total_lead_days)
                    OR orders.end_date IS NULL
                  )
              )
        SELECT item_id
        FROM
        items_to_work
        where (
          order_type = 'standing' AND
          (
            SELECT count(id)
            FROM orders
            WHERE orders.client_id = items_to_work.client_id
            AND orders.route_id = items_to_work.route_id
            AND start_date <= ship_date
            AND (end_date IS NULL OR end_date >=ship_date)
            AND orders.order_type='temporary'
          ) = 0
      )
          OR order_type != 'standing'
         )
    SQL
    where(sql, production_date: start_date)
  end
  # rubocop:enable Metrics/MethodLength

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
    ready_date = start_date + total_lead_days.days
    quantity(ready_date) > 0
  end

  def touch_order
    return unless order && !order.destroyed?
    order.last_updated_by_user_id
    order.increment(:version_number)
    order.save
  end

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
    day = date.strftime("%A").downcase.to_sym
    send(day) || 0
  end

  def daily_subtotal(date)
    quantity(date) * product.price(total_quantity)
  end

  def destroy
    self.removed = true
    save
  end
end
