class Order < ActiveRecord::Base
  belongs_to :client
  belongs_to :route
  belongs_to :bakery

  has_many :order_items, dependent: :destroy

  accepts_nested_attributes_for :order_items, allow_destroy: true,
                                              reject_if: proc { |attributes| attributes['product_id'].blank? }

  before_validation :set_end_date_to_start, if: :temporary?

  validates :route, :route_id, presence: true
  validates :client, :client_id, presence: true
  validates :start_date, presence: true
  validate  :end_date_is_not_before_start_date
  validates :order_items, presence: { message: 'You must choose a product before saving' }
  validates :order_type, presence: true, inclusion: %w(standing temporary)
  validates :bakery, presence: true
  validate  :standing_order_date_can_not_overlap

  delegate(
    :weekly_delivery_fee?,
    :daily_delivery_fee?,
    :delivery_fee,
    :delivery_minimum,
    :name,
    to: :client, prefix: true
  )

  # rubocop:disable Metrics/MethodLength
  def self.active(date)
    where('
      start_date <= :date and (end_date is null OR end_date >= :date)
      AND orders.id NOT IN (
        select ID
        FROM orders standing_orders
        WHERE order_type = :standing
        AND start_date <= :date and (end_date is null OR end_date >= :date)
        AND (
          SELECT count(id)
          FROM orders temp_orders
          WHERE order_type = :temporary
          AND standing_orders.route_id = temp_orders.route_id
          AND standing_orders.client_id = temp_orders.client_id
          AND start_date <= :date and (end_date is null OR end_date >= :date)
        ) > 0
      )
    ', date: date, standing: 'standing', temporary: 'temporary')
  end
  # rubocop:enable Metrics/MethodLength

  def self.temporary(date)
    where(order_type: 'temporary', start_date: date)
  end

  def self.standing(date)
    where(order_type: 'standing')
      .where('start_date <= ? ', date)
      .where('end_date is null or end_date >= ? ', date)
  end

  def self.sort_for_active
    includes(:client, :route)
      .joins(:client, :route)
      .order('clients.name asc')
      .order('routes.departure_time asc')
      .order(start_date: :desc)
  end

  def self.sort_for_history
    includes(:client, :route)
      .order(start_date: :desc)
  end

  def end_date_is_not_before_start_date
    return unless end_date && start_date
    return unless end_date < start_date
    errors.add(:end_date, 'The end date cannot be before the start date')
  end

  def standing_order_date_can_not_overlap
    ids = overlapping_orders.map(&:id).join(',')
    errors.add(:start_date, "This order overlaps with ids (#{ids})") if overlapping?
  end

  def overlapping?
    overlapping_orders.count > 0
  end

  def overlapping_orders
    overlapping = Order
      .where(bakery: bakery, client: client, route: route, order_type: order_type)
      .where.not(id: id)
      .where('end_date >= ? OR end_date is null', start_date)
    overlapping = overlapping.where('start_date <= ?', end_date) if end_date
    overlapping
  end

  def set_end_date_to_start
    self.end_date = start_date
  end

  def temporary?
    order_type == 'temporary'
  end

  def standing?
    order_type == 'standing'
  end

  def total_lead_days
    order_items.map(&:total_lead_days).max || 0
  end

  def daily_subtotal(date)
    order_items.reduce(0) do |sum, item|
      sum + item.daily_subtotal(date)
    end
  end
end
