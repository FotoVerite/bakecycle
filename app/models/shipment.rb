# == Schema Information
#
# Table name: shipments
#
#  id                               :integer          not null, primary key
#  client_id                        :integer          not null
#  route_id                         :integer          not null
#  date                             :date             not null
#  payment_due_date                 :date             not null
#  bakery_id                        :integer          not null
#  delivery_fee                     :decimal(, )      default(0.0), not null
#  auto_generated                   :boolean          default(FALSE), not null
#  client_name                      :string           not null
#  client_official_company_name     :string
#  client_billing_term              :string           not null
#  client_delivery_address_street_1 :string
#  client_delivery_address_street_2 :string
#  client_delivery_address_city     :string
#  client_delivery_address_state    :string
#  client_delivery_address_zipcode  :string
#  client_billing_address_street_1  :string
#  client_billing_address_street_2  :string
#  client_billing_address_city      :string
#  client_billing_address_state     :string
#  client_billing_address_zipcode   :string
#  client_billing_term_days         :integer          not null
#  route_name                       :string           not null
#  note                             :text
#  client_primary_contact_name      :string
#  client_primary_contact_phone     :string
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  route_departure_time             :time             not null
#  client_notes                     :string
#  order_id                         :integer
#  sequence_number                 :integer
#

class Shipment < ActiveRecord::Base
  include Denormalization

  belongs_to :bakery
  belongs_to :order
  belongs_to :client
  belongs_to :route

  has_many :shipment_items, dependent: :destroy

  accepts_nested_attributes_for(
    :shipment_items,
    allow_destroy: true,
    reject_if: proc { |attributes| attributes["product_id"].blank? }
  )

  before_validation :set_payment_due_date
  before_create :set_sequence_number
  after_create :increment_client_sequence

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

  delegate :after_kickoff_time?, :before_kickoff_time?, to: :bakery

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
    if client.try(:legacy_id)
      "#{sequence_number}-#{format('%03d', route.legacy_id)}-#{client.legacy_id}"
    else
      "#{sequence_number}-#{format('%03d', route_id)}-#{client_id}"
    end
  end

  def set_payment_due_date
    return unless client_billing_term_days && date
    self.payment_due_date = date + client_billing_term_days.days
  end

  def production_start
    shipment_items.earliest_production_date
  end

  def set_sequence_number
    self.sequence_number = client.sequence_number
  end

  def increment_client_sequence
    client.increment(:sequence_number)
    client.save
  end
end
