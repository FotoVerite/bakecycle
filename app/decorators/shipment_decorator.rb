class ShipmentDecorator < Draper::Decorator
  delegate_all
  decorates_association :shipment_items
  decorates_association :bakery

  def sorted_shipment_items
    object.shipment_items.order_by_product_type_and_name.decorate
  end

  def available_clients
    h.item_finder.clients.order(:name)
  end

  def available_routes
    h.item_finder.routes.order(:name)
  end

  def available_products
    h.item_finder.products.order(:name)
  end

  def auto_generated?
    auto_generated ? 'Yes' : 'No'
  end

  def price
    h.number_to_currency(object.price)
  end

  def price_for_iif
    object.price
  end

  def delivery_fee_for_iif
    object.delivery_fee
  end

  def date_for_iif
    object.date.strftime('%-m/%d/%y')
  end

  def due_date_for_iif
    object.payment_due_date.strftime('%-m/%d/%y')
  end

  def delivery_fee
    h.number_to_currency(object.delivery_fee)
  end

  def subtotal
    h.number_to_currency(object.subtotal)
  end

  def terms
    object.client_billing_term.titleize
  end

  def client_delivery_zipcode
    object.client_delivery_address_zipcode
  end

  def client_billing_zipcode
    object.client_billing_address_zipcode
  end

  def client_state_zipcode
    "#{object.client_delivery_address_state} #{client_delivery_zipcode}"
  end

  def client_delivery_city_state_zip
    "#{object.client_delivery_address_city}, #{object.client_delivery_address_state} #{client_delivery_zipcode}"
  end

  def client_billing_city_state_zip
    "#{object.client_billing_address_city}, #{object.client_billing_address_state} #{client_billing_zipcode}"
  end

  def client_billing_name
    object.client_name
  end

  def client_delivery_name
    object.client_name
  end

  delegate :logo, to: :bakery, prefix: true
  delegate :logo_local_file, to: :bakery, prefix: true # creates bakery_logo_local_file
  delegate :name, to: :bakery, prefix: true
  delegate :address_street_1, to: :bakery, prefix: true
  delegate :address_street_2, to: :bakery, prefix: true
  delegate :city_state_zip, to: :bakery, prefix: true
  delegate :phone_number, to: :bakery, prefix: true
  delegate :email, to: :bakery, prefix: true
  delegate :quickbooks_account, to: :bakery, prefix: true
end
