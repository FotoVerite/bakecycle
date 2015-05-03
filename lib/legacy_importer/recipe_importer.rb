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
      recipe_type         recipe_type
      recipe_mix_size     mix_size
    )
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
      attrs = FieldMapper.new(FIELDS_MAP).translate(data)
      attrs.merge(
        mix_size_unit: :kg,
        recipe_type: RECIPE_TYPE_MAP[attrs[:recipe_type]] || attrs[:recipe_type],
        lead_days: calculate_lead_days
      )
    end

    def calculate_lead_days
      if data[:recipe_type] == 'inclusion'
        1
      else
        data[:recipe_daystomake] - 1
      end
    end
  end
end
