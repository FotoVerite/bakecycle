class Shipment < ActiveRecord::Base
  belongs_to :client
  belongs_to :route
  belongs_to :bakery

  has_many :shipment_items

  accepts_nested_attributes_for :shipment_items, allow_destroy: true

  validates :route, :route_id, presence: true
  validates :client, :client_id, presence: true
  validates :date, presence: true
  validates :payment_due_date, presence: true

  before_validation :set_payment_due_date

  def self.search(fields)
    search_by_client(fields[:client_id])
      .search_by_date_from(fields[:date_from])
      .search_by_date_to(fields[:date_to])
      .includes(:client)
      .order("date DESC")
  end

  def self.search_by_client(client)
    return all if client.blank?
    where(client: client)
  end

  def self.search_by_date_from(date_from)
    return all if date_from.blank?
    where('date >= ?', date_from)
  end

  def self.search_by_date_to(date_to)
    return all if date_to.blank?
    where('date <= ?', date_to)
  end

  def self.recent_shipments(client)
    where(client_id: client).includes(:route).order("date DESC").limit(10)
  end

  def price
    shipment_items.reduce(0) do |sum, item|
      sum + item.price
    end
  end

  def set_payment_due_date
    return self.payment_due_date = nil unless client
    return self.payment_due_date = date if client.bill_today?
    self.payment_due_date = date + Client.get_billing_term_days(client.billing_term) if date
  end
end
