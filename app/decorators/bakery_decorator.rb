class BakeryDecorator < Draper::Decorator
  delegate_all

  def logo_path
    object.logo.path
  end

  def city_state_zip
    "#{object.address_city}, #{object.address_state} #{object.address_zipcode}"
  end
end
