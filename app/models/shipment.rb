class Shipment < ActiveRecord::Base
  belongs_to :bakery

  has_many :shipment_items, dependent: :destroy

  accepts_nested_attributes_for :shipment_items, allow_destroy: true,
                                                 reject_if: proc { |attributes| attributes['product_id'].blank? }

  before_validation :set_client_data
  before_validation :set_route_data
  before_validation :set_payment_due_date

  validates :client_id,
            :client_name,
            :client_billing_term,
            :client_billing_term_days, presence: true

  validates :route_id, :route_name, presence: true
  validates :payment_due_date, presence: true
  validates :date, presence: true
  validates :bakery, presence: true
  validates :delivery_fee, presence: true, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: true

  # will_paginate
  self.per_page = 20

  def self.search(fields)
    search_by_client(fields[:client_id])
      .search_by_date_from(fields[:date_from])
      .search_by_date_to(fields[:date_to])
      .search_by_date(fields[:date])
      .search_by_route(fields[:route_id])
      .order('date DESC')
  end

  def self.shipments_for_week(client_id, end_date)
    week = Week.new(end_date)
    search_by_client(client_id)
      .search_by_date_from(week.start_date)
      .search_by_date_to(week.end_date)
  end

  def self.search_by_date(date)
    return all if date.blank?
    where(date: date)
  end

  def self.search_by_client(client_id)
    return all if client_id.blank?
    where(client_id: client_id)
  end

  def self.search_by_route(route_id)
    return all if route_id.blank?
    where(route_id: route_id)
  end

  def self.search_by_date_from(date_from)
    return all if date_from.blank?
    where('date >= ?', date_from)
  end

  def self.search_by_date_to(date_to)
    return all if date_to.blank?
    where('date <= ?', date_to)
  end

  def self.weekly_subtotal(client_id, date)
    shipments_for_week(client_id, date).map(&:subtotal).sum
  end

  def self.recent(client_id)
    where(client_id: client_id).order('date DESC').limit(10)
  end

  def self.upcoming(order, date = Time.zone.today)
    where(client_id: order.client.id, route_id: order.route.id).where('date >= ?', date).order('date ASC')
  end

  def subtotal
    shipment_items.map(&:price).sum
  end

  def price
    subtotal + delivery_fee
  end

  def total_quantity
    shipment_items.pluck(:product_quantity).reduce(:+) || 0
  end

  def invoice_number
    "#{date.strftime('%Y%m%d')}-#{id}-#{client_id}-#{route_id}"
  end

  def set_payment_due_date
    return unless client_billing_term_days && date
    self.payment_due_date = date + client_billing_term_days.days
  end

  def set_client_data
    self.client = Client.find(client_id) if client_id
  end

  def production_start
    shipment_items.earliest_production_date
  end

  def client=(client)
    fields = [
      :id, :name, :dba, :billing_term, :billing_term_days, :delivery_address_street_1,
      :delivery_address_street_2, :delivery_address_city, :delivery_address_state,
      :delivery_address_zipcode, :billing_address_street_1, :billing_address_street_2, :billing_address_city,
      :billing_address_state, :billing_address_zipcode, :primary_contact_name, :primary_contact_phone]

    fields.each do |field|
      assign_method = "client_#{field}=".to_sym
      send(assign_method, client.send(field))
    end
  end

  def set_route_data
    self.route = Route.find(route_id) if route_id
  end

  def route=(route)
    fields = [:id, :name]

    fields.each do |field|
      assign_method = "route_#{field}=".to_sym
      send(assign_method, route.send(field))
    end
  end
end
