module LegacyImporter
  class IngredientImporter
    attr_reader :data, :bakery

    def initialize(bakery, legacy_ingredients)
      @bakery = bakery
      @data = legacy_ingredients
    end

    FIELDS_MAP = %w(
      ingredient_name name
      ingredient_description description
    ).map(&:to_sym).each_slice(2)
    # ingredient_active
    # ingredient_cost
    # ingredient_measure
    # ingredient_unit

    def import!
      ObjectFinder.new(
        Ingredient,
        bakery: bakery,
        legacy_id: data[:ingredient_id].to_s
      ).update_if_changed(attr_map)
    end

    private

    def ingredient_type
      name = data[:ingredient_name]
      return "other" if name.blank?
      Ingredient::INGREDIENT_TYPES.each do |type|
        return type if /#{type}/i =~ name
      end
      return "hydration" if /water/i =~ name
      "other"
    end

    def attr_map
      FIELDS_MAP.each_with_object({}) { |(legacy_field, field), data_hash|
        data_hash[field] = data[legacy_field] unless data[legacy_field] == ""
      }.merge(ingredient_type: ingredient_type)
    end
  end
end
