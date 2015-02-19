class Client < ActiveRecord::Base
  has_many :orders
  has_many :shipments

  belongs_to :bakery

  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery }
  validates :dba, length: { maximum: 150 }
  validates :business_phone, presence: true
  validates :delivery_address_street_1, presence: true
  validates :delivery_address_city, presence: true
  validates :delivery_address_state, presence: true
  validates :delivery_address_zipcode, presence: true
  validates :billing_address_street_1, presence: true
  validates :billing_address_city, presence: true
  validates :billing_address_state, presence: true
  validates :billing_address_zipcode, presence: true
  validates :accounts_payable_contact_name, presence: true, length: { maximum: 150 }
  validates :accounts_payable_contact_phone, presence: true
  validates :accounts_payable_contact_email, presence: true, format: { with: /\A.+@.+\..+\z/ }
  validates :primary_contact_name, presence: true, length: { maximum: 150 }
  validates :primary_contact_phone, presence: true
  validates :primary_contact_email, presence: true, format: { with: /\A.+@.+\..+\z/ }
  validates :active, inclusion: [true, false]
  validates :billing_term, presence: true
  validates :bakery, presence: true
  validates :charge_delivery_fee, inclusion: [true, false]
  validates :delivery_minimum, presence: true, numericality: true
  validates :delivery_fee, presence: true, numericality: true

  geocoded_by :full_delivery_address
  after_validation :geocode

  enum billing_term: { net_45: 45, net_30: 30, net_15: 15, net_7: 7, credit_card: 1, cod: 0 }

  def full_delivery_address
    "#{delivery_address_street_1} #{delivery_address_street_2} #{delivery_address_city} #{delivery_address_state}"
  end

  def billing_term_days
    return 0 if %w(credit_card cod).include? billing_term
    self.class.billing_terms[billing_term]
  end

  def self.billing_terms_select
    billing_terms.keys.to_a.map { |keys| [keys.humanize(capitalize: false).titleize, keys] }
  end
end
