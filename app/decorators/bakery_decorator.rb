class BakeryDecorator < Draper::Decorator
  delegate_all

  def city_state_zip
    "#{object.address_city}, #{object.address_state} #{object.address_zipcode}"
  end
end
