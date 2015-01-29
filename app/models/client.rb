class Client < ActiveRecord::Base
  has_many :orders
  has_many :shipments

  validates :name, presence: true, uniqueness: true, length: { maximum: 150 }
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

  geocoded_by :full_delivery_address
  after_validation :geocode

  BILLING_TERM_OPTIONS = { net_45: 45, net_30: 30, net_15: 15, net_7: 7, credit_card: 1, cod: 0 }

  enum billing_term: BILLING_TERM_OPTIONS

  def full_delivery_address
    "#{delivery_address_street_1} #{delivery_address_street_2} #{delivery_address_city} #{delivery_address_state}"
  end

  def self.billing_term_options
    BILLING_TERM_OPTIONS
  end

  def self.get_billing_term_days(billing_term)
    billing_terms[billing_term].days
  end

  def bill_today?
    %w(credit_card, cod).include? billing_term
  end

  def self.billing_terms_select
    billing_terms.keys.to_a.map { |keys| [keys.humanize(capitalize: false), keys] }
  end
end
