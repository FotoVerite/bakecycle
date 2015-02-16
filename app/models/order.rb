class Order < ActiveRecord::Base
  belongs_to :client
  belongs_to :route
  belongs_to :bakery

  has_many :order_items

  accepts_nested_attributes_for :order_items, allow_destroy: true

  validates :route, :route_id, presence: true
  validates :client, :client_id, presence: true
  validates :start_date, presence: true
  validates :order_items, presence: { message: "You must choose a product before saving" }
  validates :order_type, presence: true, inclusion: %w(standing temporary)
  validates :bakery, presence: true

  before_validation :set_end_date_to_start, if: :temporary?

  def self.active(client, date)
    temp_orders = temporary(date).where(client: client).to_a
    standing_orders = standing(date).where(client: client).to_a

    return standing_orders.to_a if temp_orders.empty?

    standing_orders.map do |order|
      temp_orders.find { |o| o.route_id == order.route_id } || order
    end
  end

  def self.temporary(date)
    where(order_type: 'temporary', start_date: date)
  end

  def self.standing(date)
    where(order_type: 'standing')
      .where('start_date <= ? ', date)
      .where('end_date is null or end_date >= ? ', date)
  end

  def set_end_date_to_start
    self.end_date = start_date
  end

  def temporary?
    order_type == "temporary"
  end

  def standing?
    order_type == "standing"
  end

  def lead_time
    order_items.map(&:lead_time).max || 0
  end
end
