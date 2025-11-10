# == Schema Information
#
# Table name: clients
#
#  id                             :integer          not null, primary key
#  name                           :string
#  official_company_name          :string
#  business_phone                 :string
#  business_fax                   :string
#  active                         :boolean          not null
#  delivery_address_street_1      :string
#  delivery_address_street_2      :string
#  delivery_address_city          :string
#  delivery_address_state         :string
#  delivery_address_zipcode       :string
#  billing_address_street_1       :string
#  billing_address_street_2       :string
#  billing_address_city           :string
#  billing_address_state          :string
#  billing_address_zipcode        :string
#  accounts_payable_contact_name  :string
#  accounts_payable_contact_phone :string
#  accounts_payable_contact_email :string
#  primary_contact_name           :string
#  primary_contact_phone          :string
#  primary_contact_email          :string
#  secondary_contact_name         :string
#  secondary_contact_phone        :string
#  secondary_contact_email        :string
#  latitude                       :float
#  longitude                      :float
#  billing_term                   :integer          not null
#  bakery_id                      :integer          not null
#  delivery_minimum               :decimal(, )      default(0.0), not null
#  delivery_fee                   :decimal(, )      default(0.0), not null
#  legacy_id                      :string
#  delivery_fee_option            :integer          not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  ein                            :string
#  notes                          :string
#  sequence_number                :integer          default(1)
#  alert                          :boolean          default(FALSE)
#  print_invoice                  :boolean          default(TRUE)
#  temp_vip                       :boolean          default(FALSE)
#  wholesale_manager              :string
#  group                          :string
#  channel                        :string
#

class Client < ApplicationRecord
  extend AlphabeticalOrder

  belongs_to :bakery
  has_many :orders, dependent: :destroy
  has_many :standing_orders, -> { where(order_type: "standing").includes(:order_items) }, class_name: "Order"
  has_many :price_variants, dependent: :destroy
  has_many :shipments, dependent: :destroy

  enum billing_term: { net_45: 45, net_30: 30, net_15: 15, net_7: 7, credit_card: 1, cod: 0 }
  enum delivery_fee_option: %i[no_delivery_fee daily_delivery_fee weekly_delivery_fee percentage_fee]

  enum engagement_status: { current: 0, lapsed: 1, prospective: 2 }

  enum channel_options: {
      Restaurant: "Restaurant",
      Hotel: "Hotel",
      Grocery: "Grocery",
      FoodService: "FoodService",
      Distro: "Distro",
      Coffee: "Coffee"
    }

  validates :accounts_payable_contact_email, format: { with: /\A.+@.+\..+\z/ }, allow_blank: true
  validates :active, inclusion: [true, false]
  validates :bakery, presence: true
  validates :billing_term, presence: true
  validates :delivery_fee, presence: true, numericality: true, if: :delivery_fee?
  validates :delivery_fee_option, presence: true
  validates :delivery_minimum, presence: true, numericality: true, if: :delivery_fee?
  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery_id }
  validates :primary_contact_email, format: { with: /\A.+@.+\..+\z/ }, allow_blank: true
  validates :secondary_contact_email, format: { with: /\A.+@.+\..+\z/ }, allow_blank: true
  validate :check_if_both_vip_and_vip_temp
  validate :check_percentage_fee

  geocoded_by :delivery_address_full
  after_validation :geocode, if: :needs_geocode?

  scope :active, -> { where(active: true) }
  scope :vips, -> { where(alert: true) }
  scope :temp_vips, -> { where(temp_vip: true) }

  def self.billing_terms_select
    billing_terms.keys.map { |key| [key.humanize(capitalize: false).titleize, key] }
  end

  def self.delivery_fee_options_select
    delivery_fee_options.keys.map { |key| [key.humanize(capitalize: false).titleize, key] }
  end

  def self.engagement_status_select
    engagement_statuses.keys.map { |key| [key.humanize(capitalize: false).titleize, key] }
  end

  def delivery_fee?
    !no_delivery_fee?
  end

  def delivery_address
    @_delivery_address ||= Address.new(self, "delivery_address")
  end

  def billing_address
    @_billing_address ||= Address.new(self, "billing_address")
  end

  delegate :full, to: :delivery_address, prefix: true

  def billing_term_days
    return 0 if %w[credit_card cod].include? billing_term
    self.class.billing_terms[billing_term]
  end
  
  def calculate_delivery_fee(subtotal)
      return delivery_fee unless delivery_fee_option == "percentage_fee"
      subtotal * (delivery_fee / 100.00)
  end

  def display_fee
    return delivery_fee unless delivery_fee_option == "percentage_fee"
    "#{format('%.2f', delivery_fee)}%"
  end
  
    

  def average_sale_by_month
    months_hash = {}
    h = shipments
      .where(:created_at => (Time.now.beginning_of_year.all_year))
      .group(["EXTRACT(month FROM created_at)"]) 
      .order("EXTRACT(month FROM created_at)")
      .sum(:cached_price)
    months = Hash[(1..12).map { |month| [ month.to_f, 0 ] }].merge(h)
    months.map {|k, v| months_hash["#{Time.now.year}-" + k.to_i.to_s] = v.to_f } 
    months_hash
  end

  def average_sale_by_week
    weeks = shipments.where(:created_at => ((Time.now.beginning_of_week - 51.weeks)..Time.now.beginning_of_week))
    .group(["EXTRACT(week FROM created_at)"]) 
    .order("EXTRACT(week FROM created_at)")
    .sum(:cached_price)
    weeks = Hash[(1..51).map { |week| [ week.to_f, 0 ] }].merge(weeks)
    weeks = weeks.values.in_groups_of(4,false).map {|x| x.reduce(:+)}
    weeks.inject{ |sum, el| sum + el }.to_f / weeks.size
  end

  def average_four_week_sales(time)
    weeks = shipments.where(created_at: (time - 4.weeks)..time)
    return 0 if weeks.empty?
    weeks.sum(&:price) / weeks.size
  end

  def average_last_four_weeks_per_week(time)
  # Define the 4-week period (starting from 4 weeks ago)
  start_date = (time - 4.weeks).beginning_of_week
  end_date   = time.end_of_week

  # Get weekly totals from shipments
  weekly_totals = shipments
    .where(created_at: start_date..end_date)
    .group("DATE_TRUNC('week', created_at)")
    .sum(:cached_price)
  # Fill missing weeks with 0
  all_weeks = (0..3).map { |i| (start_date + i.weeks).beginning_of_week }
  weekly_values = all_weeks.map { |week| weekly_totals[week] || 0 }
  # Average of the 4 weeks
  weekly_values.sum.to_f / weekly_values.size
end
  

  private

  def needs_geocode?
    new_and_blank = new_record? && latitude.blank? && longitude.blank?
    persisted_and_changed = persisted? && delivery_address.changed?
    new_and_blank || persisted_and_changed
  end

  def check_if_both_vip_and_vip_temp
    return true unless alert && temp_vip
    errors.add(:base, "Client cannot be a VIP and a Temp VIP at the same time. ")
    false
  end

  def check_percentage_fee
    return unless delivery_fee_option == "percentage_fee"
    return if delivery_fee.blank?
    return if delivery_fee >= -100 && delivery_fee <= 100
    errors.add(:delivery_fee, "must be between -100 and 100 when fee is a percentage")
  end
end
