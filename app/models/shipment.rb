class Shipment < ActiveRecord::Base
  belongs_to :client
  belongs_to :route

  has_many :shipment_items

  accepts_nested_attributes_for :shipment_items, allow_destroy: true

  validates :route, :route_id, presence: true
  validates :client, :client_id, presence: true
  validates :shipment_date, presence: true
  validates :payment_due_date, presence: true

  before_validation :set_payment_due_date

  def set_payment_due_date
    return self.payment_due_date = nil unless client
    return self.payment_due_date = shipment_date if client.bill_today?
    self.payment_due_date = shipment_date + Client.get_billing_term_days(client.billing_term) if shipment_date
  end
end
