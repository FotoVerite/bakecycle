require 'mysql2'
require 'uri'
require 'csv'

class LegacyIngredientImporter
  attr_reader :connection, :bakery

  def initialize(bakery:, connection:)
    @bakery = bakery
    @connection = connection
  end

  def import!
    ingredients.map { |i| Importer.new(i, bakery).import! }.compact.partition(&:valid?)
  end

  def ingredients
    connection.query('SELECT * FROM bc_ingredients', symbolize_keys: true, stream: true)
  end

  class Importer
    FIELDS_MAP = %w(
      ingredient_name           name
      ingredient_cost           price
      ingredient_measure        measure
      ingredient_unit           unit
      ingredient_description    description
      ingredient_type           ingredient_type
    ).map(&:to_sym).each_slice(2)
    # ingredient_active         active

    attr_reader :data, :bakery

    def initialize(legacy_ingredient, bakery)
      @data = legacy_ingredient
      @bakery = bakery
    end

    def import!
      ingredient = Ingredient.where(
        legacy_id: data[:ingredient_id].to_s,
        bakery: bakery
      ).first_or_initialize
      ingredient.update(attributes)
      ingredient
    end

    def attributes
      attrs = attr_map
      attrs[:unit] ||= :kg
      attrs
    end

    def attr_map
      FIELDS_MAP.each_with_object({}) do |(legacy_field, field), data_hash|
        data_hash[field] = data[legacy_field] unless data[legacy_field] == ''
      end
    end
  end
end
