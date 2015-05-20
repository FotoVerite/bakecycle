class ClientDecorator < Draper::Decorator
  delegate_all

  def active_status
    active ? 'Yes' : 'No'
  end

  def billing
    billing_term.humanize(capitalize: false).titleize if billing_term
  end

  def delivery_fee_display
    delivery_fee_option.humanize(capitalize: false).titleize if delivery_fee_option
  end

  def delivery_address
    "#{delivery_address_street_1} #{delivery_address_street_2}" \
    "#{delivery_address_city} #{delivery_address_state} #{delivery_address_zipcode}"
  end
end
