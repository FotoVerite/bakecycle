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

  def street_zipcode
    "#{object.delivery_address_street_1}, #{object.delivery_address_zipcode}"
  end
end
