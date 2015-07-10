class BaseSearchForm
  attr_reader :params

  def self.params
    @params ||= []
  end

  def self.accessible_fields
    @accessible_fields ||= []
  end

  def self.search_for_many(*fields)
    fields.each do |field|
      accessible_fields.push(field)
      params.push(field => [])

      define_method field do
        process_array params[field]
      end
      define_method :"#{field}=" do |value|
        params[field] = value
      end
    end
  end

  def self.search_for_date(*fields)
    fields.each do |field|
      accessible_fields.push(field)
      params.push(field)

      define_method field do
        parse_date params[field]
      end
      define_method :"#{field}=" do |value|
        params[field] = value
      end
    end
  end

  def initialize(params)
    @params = params || {}
  end

  def to_h
    self.class.accessible_fields.each_with_object({}) do |field, object|
      object[field] = send(field)
    end
  end

  delegate :[], to: :to_h

  private

  def parse_date(date)
    date = Chronic.parse(date)
    date.to_date if date
  end

  def process_array(input)
    Array.wrap(input).reject(&:blank?)
  end
end
