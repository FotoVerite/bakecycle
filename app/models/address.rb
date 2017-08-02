class Address
  attr_reader :object, :address_type

  ADDRESS_FIELDS = %i(
    street_1
    street_2
    city
    state
    zipcode
  ).freeze

  def initialize(object, address_type)
    @object = object
    @address_type = address_type
    create_methods
  end

  def blank?
    ADDRESS_FIELDS.map { |field| send(field).blank? }.all?
  end

  def changed?
    ADDRESS_FIELDS.map { |field|
      object.send(:"#{address_type}_#{field}_changed?")
    }.any?
  end

  def full
    street_2_nl = "#{street_2}\n" if street_2.present?
    city_comma = "#{city}, " if city.present?
    state_sp = "#{state} " if state.present?
    "#{street_1}\n#{street_2_nl}#{city_comma}#{state_sp}#{zipcode}".strip
  end

  def full_array
    full.split("\n")
  end

  private

  def create_methods
    ADDRESS_FIELDS.each do |field|
      define_singleton_method field do
        object.send(:"#{address_type}_#{field}")
      end

      define_singleton_method "#{field}=" do |value|
        object.send(:"#{address_type}_#{field}=", value)
      end
    end
  end
end
