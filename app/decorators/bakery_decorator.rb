class BakeryDecorator < Draper::Decorator
  delegate_all

  def city_state_zip
    "#{object.address_city}, #{object.address_state} #{object.address_zipcode}"
  end

  def logo_errors?
    object.errors[:logo].any? || object.errors[:logo_content_type].any?
  end
end
