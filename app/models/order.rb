# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id                      :integer          not null, primary key
#  client_id               :integer          not null
#  route_id                :integer
#  start_date              :date             not null
#  end_date                :date
#  note                    :text             default(""), not null
#  order_type              :string           not null
#  bakery_id               :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  legacy_id               :integer
#  total_lead_days         :integer          not null
#  version_number          :integer          default(0)
#  created_by_user_id      :integer
#  last_updated_by_user_id :integer
#  alert                   :boolean          default(FALSE)
#  cancellation_override   :boolean          default(FALSE), not null
#

class Order < ApplicationRecord
  attr_accessor :confirm_override, :kickoff_time

  belongs_to :client
  belongs_to :route, optional: true
  belongs_to :bakery
  belongs_to :created_by_user, class_name: "User", inverse_of: :created_orders, optional: true
  belongs_to :last_updated_by_user, class_name: "User", inverse_of: :orders_last_updated_by, optional: true

  has_many :products, through: :order_items

  has_many :order_items, lambda {
    where(removed: false)
      .joins(:product)
      .includes(:product)
      .order("products.name ASC")
  },
           dependent: :destroy,
           inverse_of: :order
  has_many :all_order_items, dependent: :destroy, class_name: "OrderItem", inverse_of: :order

  has_many :shipments, dependent: :nullify

  accepts_nested_attributes_for(
    :order_items,
    allow_destroy: true,
    reject_if: proc { |attributes| attributes["product_id"].blank? }
  )

  before_validation :set_end_date_to_start, if: :temporary?

  validates :route_id, presence: true
  validates :client_id, presence: true
  validates :start_date, presence: true
  validate  :end_date_is_not_before_start_date
  validates :order_type, presence: true, inclusion: %w[standing temporary]
  validates :bakery, presence: true
  validates :discount, inclusion: 0..100, allow_nil: true

  validates_with OverlappingOrdersValidator

  delegate(
    :weekly_delivery_fee?,
    :daily_delivery_fee?,
    :percentage_fee?,
    :delivery_fee,
    :delivery_minimum,
    :name,
    :calculate_delivery_fee,
    to: :client, prefix: true
  )

  delegate :after_kickoff_time?, :before_kickoff_time?, to: :bakery

  before_save :set_total_lead_days
  after_touch :update_total_lead_days

  scope :search, ->(terms) { OrderSearcher.search(self, terms) }
  scope :active_orders, -> { where("end_date IS NULL OR end_date >= ?", Time.zone.today) }
  scope :created_at_date, ->(date = Time.zone.today) { where(created_at: date.beginning_of_day..date.end_of_day) }
  scope :updated_at_date, lambda { |date = Time.zone.today|
    where(updated_at: date.beginning_of_day..date.end_of_day)
      .where("version_number > 0")
  }

  def self.policy_class
    ClientPolicy
  end

  def self.active(date)
    sql = <<-SQL
      orders.id in (
        SELECT DISTINCT ON (client_id, route_id) id
        FROM orders
        WHERE start_date <= :date and (end_date IS NULL OR end_date >= :date)
        ORDER BY client_id, route_id, order_type DESC
      )
    SQL
    where(sql, date: date)
  end

  def self.production_date(date)
    where(id: OrderItem.production_date(date).select(:order_id))
  end

  def no_outstanding_shipments?
    missing_shipment_dates.empty?
  end

  # rubocop:disable Metrics/AbcSize
  def missing_shipment_dates(for_date_time = Time.zone.now)
    last_date = for_date_time + total_lead_days.days
    dates = []
    (for_date_time.to_date..last_date.to_date).each do |date|
      # if it's before kickoff we do not expect the next active invoice by lead time to be ready
      next if date == (for_date_time + total_lead_days.days).to_date && before_kickoff_time?
      # test if for this day of the week there are any items. If not there should be no invoice.
      next if order_items.sum(date.strftime("%A").downcase).zero?
      next if self.class.active(date).where(id: id).empty?

      dates.push date if shipments.where(date: date).empty?
    end
    dates
  end
  # rubocop:enable Metrics/AbcSize

  # Batched equivalent of `orders.reject(&:no_outstanding_shipments?)` for a
  # whole scope. #missing_shipment_dates recomputes "is this the active order
  # for (client_id, route_id) on date X" via a full-table DISTINCT-ON per date
  # per order. This computes it once per date for all orders, then looks up in
  # Ruby. Returns { order_id => [missing dates] }; absent order_id = no missing.
  def self.missing_shipment_dates_for(orders, for_date_time: Time.zone.now)
    orders = orders.to_a
    return {} if orders.empty?

    order_ids = orders.map(&:id)
    today = for_date_time.to_date
    date_range = today..(today + orders.map(&:total_lead_days).max.days)

    day_sums = weekday_sums_by_order(order_ids)
    active_ids_by_date = active_order_ids_by_date(orders, date_range)
    shipment_dates_by_order = Shipment.where(order_id: order_ids, date: date_range)
      .pluck(:order_id, :date)
      .group_by(&:first)
      .transform_values { |rows| rows.map(&:second).to_set }

    orders.each_with_object({}) do |order, result|
      last_date = (for_date_time + order.total_lead_days.days).to_date
      dates = (today..last_date).select do |date|
        next false if date == last_date && order.before_kickoff_time?
        next false if day_sums.dig(order.id, date.strftime("%A").downcase).to_i.zero?
        next false unless active_ids_by_date[date]&.include?(order.id)

        !shipment_dates_by_order[order.id]&.include?(date)
      end
      result[order.id] = dates if dates.any?
    end
  end

  # One query total: SUM all weekday columns for all orders at once.
  # Returns { order_id => { "monday" => 5, "tuesday" => 10, ... } }
  def self.weekday_sums_by_order(order_ids)
    columns = OrderItem::DAYS_OF_WEEK
    selects = [Arel.sql("order_id")] + columns.map { |day| Arel.sql("SUM(#{day})") }

    OrderItem.where(order_id: order_ids, removed: false)
      .group(:order_id)
      .pluck(*selects)
      .to_h do |row|
        [row.first, columns.zip(row.drop(1)).to_h { |day, sum| [day.to_s, sum] }]
      end
  end
  private_class_method :weekday_sums_by_order

  # One query per unique date needed (not per order). Scoped to this batch's
  # own client/route combos, so Postgres doesn't sort the entire orders table.
  # Returns { date => Set[order_ids_active_on_that_date] }
  def self.active_order_ids_by_date(orders, date_range)
    client_ids = orders.map(&:client_id).uniq
    route_ids = orders.map(&:route_id).uniq

    date_range.index_with do |date|
      sql = <<-SQL
        SELECT DISTINCT ON (client_id, route_id) id
        FROM orders
        WHERE client_id IN (?) AND route_id IN (?)
          AND start_date <= ? AND (end_date IS NULL OR end_date >= ?)
        ORDER BY client_id, route_id, order_type DESC
      SQL
      find_by_sql([sql, client_ids, route_ids, date, date]).map(&:id).to_set
    end
  end
  private_class_method :active_order_ids_by_date

  # sorts orders by their end date, putting open ended standing orders in for today
  def self.order_by_active
    order(Arel.sql("COALESCE(orders.end_date, now()) DESC"))
  end

  def self.temporary(date)
    where(order_type: "temporary", start_date: date)
  end

  # SQL equivalent of #still_in_use, for scopes that need to filter/paginate in the
  # database instead of loading every row into Ruby to check still_in_use on each.
  scope :still_in_use, lambda {
    today = Time.zone.today
    where(
      "(order_type = 'temporary' AND start_date >= :today) OR " \
      "(order_type = 'standing' AND (end_date IS NULL OR end_date >= :today))",
      today: today
    )
  }

  def self.standing(date)
    where(order_type: "standing")
      .where("start_date <= ? ", date)
      .where("end_date is null or end_date >= ? ", date)
  end

  def set_total_lead_days
    self.total_lead_days = order_items.maximum(:total_lead_days) || 1
  end

  def update_total_lead_days
    update_columns(total_lead_days: set_total_lead_days) if persisted?
  end

  def end_date_is_not_before_start_date
    return unless end_date && start_date
    return unless end_date < start_date

    errors.add(:end_date, "The end date cannot be before the start date")
  end

  def set_end_date_to_start
    self.end_date = start_date
  end

  def overlapping_orders
    return Order.none unless start_date

    overlapping = Order
      .where(bakery: bakery, client: client, route: route, order_type: order_type)
      .where.not(id: id)
      .where("end_date >= ? OR end_date is null", start_date)
    overlapping = overlapping.where("start_date <= ?", end_date) if end_date
    overlapping
  end

  def overlapping?
    overlapping_orders.any?
  end

  def overridable_order
    return if overlapping_orders.count > 1

    overrideable = overlapping_orders.where("start_date < ?", start_date)
    overrideable = overrideable.where("end_date <= ? OR end_date is null", end_date) if end_date
    overrideable.last
  end

  def overridable_order?
    overridable_order.present?
  end

  def temporary?
    order_type == "temporary"
  end

  def standing?
    order_type == "standing"
  end

  def daily_subtotal(date)
    order_items.reduce(0) do |sum, item|
      sum + item.daily_subtotal(date)
    end
  end

  def still_in_use
    if temporary?
      start_date >= Time.zone.today
    elsif standing?
      end_date.blank? || end_date >= Time.zone.today
    end
  end

  def ended?
    end_date.present? && end_date < Time.zone.today
  end
end
