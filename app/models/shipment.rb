# frozen_string_literal: true

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
#  sequence_number                  :integer
#  alert                            :boolean          default(FALSE)
#

class Shipment < ApplicationRecord
  include Denormalization

  belongs_to :bakery
  belongs_to :order, optional: true
  belongs_to :client
  belongs_to :route

  has_many :shipment_items, dependent: :destroy

  attribute :discount_type, :integer

  enum :discount_type, { fixed_amount: 0, percentage: 1 }, prefix: :discount

  accepts_nested_attributes_for(
    :shipment_items,
    allow_destroy: true,
    reject_if: proc { |attributes| attributes["product_id"].blank? }
  )

  before_validation :set_payment_due_date
  before_validation :apply_client_default_discount, on: :create
  before_create :set_sequence_number
  after_create :increment_client_sequence, :send_to_contact
  before_update :check_delivery_fee?
  before_update :cache_price

  validates :date, presence: true
  validates :bakery, presence: true
  validates :payment_due_date, presence: true
  validates :delivery_fee, presence: true, numericality: true
  validates :client_id, presence: true
  validates :route_id, presence: true
  validates :discount_value, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validate :check_discount

  # create route= and route_id= methods
  denormalize :route, %i[id name departure_time]

  # create client= and client_id= methods
  denormalize :client, %i[
    id name official_company_name billing_term billing_term_days delivery_address_street_1
    delivery_address_street_2 delivery_address_city delivery_address_state
    delivery_address_zipcode billing_address_street_1 billing_address_street_2
    billing_address_city billing_address_state billing_address_zipcode
    primary_contact_name primary_contact_phone notes
  ]

  delegate :after_kickoff_time?, :before_kickoff_time?, to: :bakery

  scope :search, ->(terms) { ShipmentSearcher.search(all, terms) }
  scope :latest, ->(count) { order(date: :desc).limit(count) }

  # Billing-facing reports (revenue, invoice exports) must not treat
  # sample-order shipments as real invoices -- they're deliberately free
  # tastings. left_joins (not joins) + the explicit IS NULL branch is
  # required: a plain `where.not(orders: { order_type: "sample" })` would
  # also silently drop any shipment with no linked order at all, since SQL's
  # `NULL != 'sample'` evaluates to NULL, not true, and WHERE discards NULL
  # rows.
  scope :non_sample, -> { left_joins(:order).where("orders.id IS NULL OR orders.order_type != 'sample'") }

  delegate :sample?, to: :order, allow_nil: true

  def self.policy_class
    ClientPolicy
  end

  # Shipments that share the same date/client/route -- almost always a
  # double-billing mistake (same delivery invoiced twice). Sample-order
  # invoices are deliberately allowed to duplicate a standing/temporary
  # invoice's date/client/route, so they're excluded from this check entirely
  # -- both as a flagged shipment and as a reason to flag another shipment.
  def self.duplicate_invoices(bakery, date_range)
    where(bakery_id: bakery, date: date_range)
      .includes(:order)
      .reject { |shipment| shipment.order&.sample? }
      .group_by { |shipment| [shipment.date, shipment.client_id, shipment.route_id] }
      .select { |_key, shipments| shipments.size > 1 }
      .values.flatten
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

  def self.discount_types_select
    [["$ Amount", "fixed_amount"], ["Percentage", "percentage"]]
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

  def discount?
    discount_type.present? && discount_value.present? && discount_value.positive?
  end

  def discount_base_amount
    subtotal
  end

  def discount_amount
    return 0.to_d unless discount?

    amount = if discount_percentage?
               discount_base_amount * (discount_value / 100.to_d)
             else
               discount_value
             end

    [amount, subtotal + delivery_fee].min
  end

  def price
    [subtotal + delivery_fee - discount_amount, 0.to_d].max
  end

  def cache_price
    self.cached_price = price
  end

  def total_quantity
    shipment_items.map(&:product_quantity).sum
  end

  def invoice_number
    if client.try(:legacy_id)
      "#{sequence_number}-#{format('%05d', client.legacy_id)}"
    else
      "#{sequence_number}-#{format('%05d', client_id)}"
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

  def check_delivery_fee?
    return self.delivery_fee = 0 unless charge_precentage_fee? || charge_daily_fee? || charge_weekly_fee?

    self.delivery_fee = order.client_calculate_delivery_fee(subtotal)
  end

  def charge_precentage_fee?
    return false if order.blank?
    return false unless order.client_percentage_fee?
    return false if shipment_items.empty?

    shipment_items_subtotal > order.client_delivery_minimum
  end

  def charge_daily_fee?
    return false if order.blank?
    return false unless order.client_daily_delivery_fee?
    return false if shipment_items.empty?

    shipment_items_subtotal < order.client_delivery_minimum
  end

  def charge_weekly_fee?
    return false unless order

    order.client_weekly_delivery_fee? && date.sunday? && weekly_subtotal_too_low?
  end

  def weekly_subtotal_too_low?
    (weekly_subtotal + shipment_items_subtotal) < order.client_delivery_minimum
  end

  def weekly_subtotal
    Shipment.weekly_subtotal(order.client_id, date)
  end

  def shipment_items_subtotal
    shipment_items.sum(&:price)
  end

  def send_to_contact
    nil unless client.accounts_payable_contact_email && client.send_shipment_when_generated
    # ClientsMailer.send_invoice(self).deliver_now
  end

  def apply_client_default_discount
    return if discount_type.present? || discount_value.present?
    return unless client&.default_discount?

    self.discount_type = client.default_discount_type
    self.discount_value = client.default_discount_value
  end

  def check_discount
    if discount_type.present? && discount_value.blank?
      errors.add(:discount_value, "must be present when a discount type is selected")
    end

    if discount_value.present? && discount_type.blank?
      errors.add(:discount_type, "must be present when a discount value is entered")
    end

    return unless discount_percentage? && discount_value.to_d > 100

    errors.add(:discount_value, "must be less than or equal to 100 for percentage discounts")
  end
end
