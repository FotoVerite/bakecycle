class Client < ActiveRecord::Base
  has_many :orders

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
  validates :accounts_payable_contact_email, presence: true, format: { with: /@/ }
  validates :primary_contact_name, presence: true, length: { maximum: 150 }
  validates :primary_contact_phone, presence: true
  validates :primary_contact_email, presence: true, format: { with: /@/ }

  geocoded_by :full_delivery_address
  after_validation :geocode

  def full_delivery_address
    "#{delivery_address_street_1} #{delivery_address_street_2} #{delivery_address_city} #{delivery_address_state}"
  end
end
