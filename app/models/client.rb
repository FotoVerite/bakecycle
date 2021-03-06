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
#

class Client < ApplicationRecord
  extend AlphabeticalOrder

  belongs_to :bakery
  has_many :orders, dependent: :destroy
  has_many :price_variants, dependent: :destroy
  has_many :shipments

  enum billing_term: { net_45: 45, net_30: 30, net_15: 15, net_7: 7, credit_card: 1, cod: 0 }
  enum delivery_fee_option: %i[no_delivery_fee daily_delivery_fee weekly_delivery_fee]

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

  geocoded_by :delivery_address_full
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

  private

  def needs_geocode?
    new_and_blank = new_record? && latitude.blank? && longitude.blank?
    persisted_and_changed = persisted? && delivery_address.changed?
    new_and_blank || persisted_and_changed
  end
end
