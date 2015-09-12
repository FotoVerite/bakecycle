class Shipment < ActiveRecord::Base
  include Denormalization

  belongs_to :bakery
  has_many :shipment_items, dependent: :destroy

  accepts_nested_attributes_for(
    :shipment_items,
    allow_destroy: true,
    reject_if: proc { |attributes| attributes["product_id"].blank? }
  )

  before_validation :set_payment_due_date

  validates :date, presence: true
  validates :bakery, presence: true
  validates :payment_due_date, presence: true
  validates :delivery_fee, presence: true, numericality: true
  validates :client_id, presence: true
  validates :route_id, presence: true

  # create route= and route_id= methods
  denormalize :route, [:id, :name, :departure_time]

  # create client= and client_id= methods
  denormalize :client, [
    :id, :name, :official_company_name, :billing_term, :billing_term_days, :delivery_address_street_1,
    :delivery_address_street_2, :delivery_address_city, :delivery_address_state,
    :delivery_address_zipcode, :billing_address_street_1, :billing_address_street_2,
    :billing_address_city, :billing_address_state, :billing_address_zipcode,
    :primary_contact_name, :primary_contact_phone, :notes
  ]

  scope :search, ->(terms) { ShipmentSearcher.search(self, terms) }
  scope :latest, -> (count) { order(date: :desc).limit(count) }

  def self.policy_class
    ClientPolicy
  end

  def self.weekly_subtotal(client_id, date)
    week = Week.new(date)
    search(
      client_id: client_id,
      date_from: week.start_date,
      date_to: week.end_date
    ).to_a.sum(&:subtotal)
  end

  def self.upcoming(date)
    where("date >= ?", date).order("date ASC")
  end

  def self.order_by_route_and_client
    order("route_departure_time asc, route_name asc, client_name asc")
  end

  def client_delivery_address
    @_client_delivery_address ||= Address.new(self, "client_delivery_address")
  end

  def client_billing_address
    @_client_billing_address ||= Address.new(self, "client_billing_address")
  end

  def subtotal
    shipment_items.map(&:price).sum
  end

  def price
    subtotal + delivery_fee
  end

  def total_quantity
    shipment_items.map(&:product_quantity).sum
  end

  def invoice_number
    "#{id}-#{client_id}"
  end

  def set_payment_due_date
    return unless client_billing_term_days && date
    self.payment_due_date = date + client_billing_term_days.days
  end

  def production_start
    shipment_items.earliest_production_date
  end
end
