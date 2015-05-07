module LegacyImporter
  class IngredientImporter
    attr_reader :data, :bakery

    def initialize(bakery, legacy_ingredients)
      @bakery = bakery
      @data = legacy_ingredients
    end

    FIELDS_MAP = %w(
      ingredient_name           name
      ingredient_cost           price
      ingredient_measure        measure
      ingredient_unit           unit
      ingredient_description    description
      ingredient_type           ingredient_type
    ).map(&:to_sym).each_slice(2)
    # ingredient_active         active

    def import!
      ObjectFinder.new(
        Ingredient,
        bakery: bakery,
        legacy_id: data[:ingredient_id].to_s
      ).update_if_changed(attributes)
    end

    private

    def attributes
      attrs = attr_map
      attrs.merge(unit: attrs[:units] || :kg)
    end

    def attr_map
      FIELDS_MAP.each_with_object({}) do |(legacy_field, field), data_hash|
        data_hash[field] = data[legacy_field] unless data[legacy_field] == ''
      end
    end
  end
end
