class Client < ActiveRecord::Base
  extend AlphabeticalOrder

  belongs_to :bakery
  has_many :orders, dependent: :destroy
  has_many :price_variants, dependent: :destroy
  has_many :shipments

  enum billing_term: { net_45: 45, net_30: 30, net_15: 15, net_7: 7, credit_card: 1, cod: 0 }
  enum delivery_fee_option: [:no_delivery_fee, :daily_delivery_fee, :weekly_delivery_fee]

  validates :accounts_payable_contact_email, format: { with: /\A.+@.+\..+\z/ }, allow_blank: true
  validates :active, inclusion: [true, false]
  validates :bakery, presence: true
  validates :billing_term, presence: true
  validates :delivery_fee, presence: true, numericality: true, if: :delivery_fee?
  validates :delivery_fee_option, presence: true
  validates :delivery_minimum, presence: true, numericality: true, if: :delivery_fee?
  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery }
  validates :primary_contact_email, format: { with: /\A.+@.+\..+\z/ }, allow_blank: true
  validates :secondary_contact_email, format: { with: /\A.+@.+\..+\z/ }, allow_blank: true

  geocoded_by :full_delivery_address
  after_validation :geocode, if: :needs_geocode?

  scope :active, -> { where(active: true) }

  def self.billing_terms_select
    billing_terms.keys.map { |key| [key.humanize(capitalize: false).titleize, key] }
  end

  def self.delivery_fee_options_select
    delivery_fee_options.keys.map { |key| [key.humanize(capitalize: false).titleize, key] }
  end

  def delivery_fee?
    !no_delivery_fee?
  end

  def full_delivery_address
    [
      delivery_address_street_1,
      delivery_address_street_2,
      delivery_address_city,
      delivery_address_state,
      delivery_address_zipcode
    ].compact.join(" ")
  end

  def billing_term_days
    return 0 if %w(credit_card cod).include? billing_term
    self.class.billing_terms[billing_term]
  end

  private

  def delivery_address_changed?
    delivery_address_street_1_changed? ||
      delivery_address_street_2_changed? ||
      delivery_address_city_changed? ||
      delivery_address_state_changed? ||
      delivery_address_zipcode_changed?
  end

  def needs_geocode?
    if new_record?
      latitude.nil? && longitude.nil?
    else
      delivery_address_changed?
    end
  end
end
