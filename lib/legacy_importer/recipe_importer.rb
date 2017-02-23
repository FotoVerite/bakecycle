module LegacyImporter
  class RecipeImporter
    attr_reader :data, :bakery

    def initialize(bakery, legacy_recipe)
      @bakery = bakery
      @data = legacy_recipe
    end

    FIELDS_MAP = %w(
      recipe_name name
      recipe_instructions note
      recipe_type recipe_type
      recipe_mix_size mix_size
    ).freeze
    # recipe_extra
    # recipe_active
    # recipe_print

    RECIPE_TYPE_MAP = {
      "motherdough" => :dough
    }.freeze

    def import!
      ObjectFinder.new(
        Recipe,
        bakery: bakery,
        legacy_id: data[:recipe_id].to_s
      ).update_if_changed(attributes)
        .tap { |recipe|
        add_levain_feeder_to_levain(recipe)
      }
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
      if data[:recipe_type] == "preferment"
        1
      else
        data[:recipe_daystomake] - 1
      end
    end

    def add_levain_feeder_to_levain(recipe)
      return unless recipe.name == "Levain"
      levain_feeder = Ingredient.find_or_create_by(
        bakery: bakery,
        name: "Feeding Levain",
        ingredient_type: "other"
      )
      recipe.recipe_items.find_or_create_by(inclusionable: levain_feeder, bakers_percentage: 50, sort_id: 100)
    end
  end
end
