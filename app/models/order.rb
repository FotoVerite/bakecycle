class Order < ActiveRecord::Base
  attr_accessor :confirm_override
  attr_accessor :kickoff_time

  belongs_to :client
  belongs_to :route
  belongs_to :bakery

  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_many :shipments

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
  validates :order_type, presence: true, inclusion: %w(standing temporary)
  validates :bakery, presence: true
  validates_with OverlappingOrdersValidator

  delegate(
    :weekly_delivery_fee?,
    :daily_delivery_fee?,
    :delivery_fee,
    :delivery_minimum,
    :name,
    to: :client, prefix: true
  )

  before_save :set_total_lead_days
  after_touch :update_total_lead_days

  scope :search, ->(terms) { OrderSearcher.search(self, terms) }

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

  def processed_shipment_for_today?
    return true unless Time.zone.today >= start_date && (end_date.nil? || Time.zone.today < end_date)
    return true unless after_kickoff_time?
    !shipments.upcoming(Time.zone.today).empty?
  end

  # sorts orders by their end date, putting open ended standing orders in for today
  def self.order_by_active
    order("COALESCE(orders.end_date, now()) DESC")
  end

  def self.temporary(date)
    where(order_type: "temporary", start_date: date)
  end

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

  private

  def after_kickoff_time?
    kickoff = bakery.kickoff_time
    now = Time.zone.now
    # Add a few minutes to account for processing time.
    kickoff_today = Time.zone.local(now.year, now.month, now.day, kickoff.hour, kickoff.min, kickoff.sec) + 5.minutes
    kickoff_today <= now
  end
end
