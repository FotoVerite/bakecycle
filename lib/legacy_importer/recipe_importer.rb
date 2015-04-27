module LegacyImporter
  class RecipeImporter
    attr_reader :data, :bakery

    def initialize(bakery, legacy_recipe)
      @bakery = bakery
      @data = legacy_recipe
    end

    FIELDS_MAP = %w(
      recipe_name         name
      recipe_instructions note
      recipe_daystomake   lead_days
      recipe_type         recipe_type
      recipe_mix_size     mix_size
    ).map(&:to_sym).each_slice(2)
    # recipe_extra
    # recipe_active
    # recipe_print

    RECIPE_TYPE_MAP = {
      'motherdough' => :dough
    }

    def import!
      ObjectFinder.new(
        Recipe,
        bakery: bakery,
        legacy_id: data[:recipe_id].to_s
      ).update(attributes)
    end

    private

    def attributes
      attrs = attr_map
      attrs.merge(
        mix_size_unit: :kg,
        recipe_type: RECIPE_TYPE_MAP[attrs[:recipe_type]] || attrs[:recipe_type]
      )
    end

    def attr_map
      FIELDS_MAP.each_with_object({}) do |(legacy_field, field), data_hash|
        data_hash[field] = data[legacy_field] unless data[legacy_field] == ''
      end
    end
  end
end
