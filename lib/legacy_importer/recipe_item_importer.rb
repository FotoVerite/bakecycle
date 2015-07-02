module LegacyImporter
  class RecipeItemImporter
    attr_reader :data, :bakery

    def initialize(bakery, legacy_recipe_item)
      @bakery = bakery
      @data = legacy_recipe_item
    end

    def import!
      return SkippedRecipeItem.new(data) if skip?
      ObjectFinder.new(
        RecipeItem,
        recipe_id: recipe.try(:id),
        inclusionable: inclusionable
      ).update_if_changed(
        bakers_percentage: data[:recipeamt_bakerspct],
        sort_id: sort_id
      )
    end

    class SkippedRecipeItem < SkippedObject
    end

    private

    def sort_id
      if inclusionable.is_a? Ingredient
        Ingredient::INGREDIENT_TYPES.index(inclusionable.ingredient_type) || 100
      else
        100
      end
    end

    def inclusionable
      @_inclusionable ||= ingredient || included_recipe
    end

    def skip?
      data[:recipeamt_bakerspct] == 0
    end

    def recipe
      Recipe.where(bakery: bakery, legacy_id: data[:recipeamt_recipeid]).first
    end

    def ingredient
      Ingredient.where(bakery: bakery, legacy_id: data[:recipeamt_ingredientid]).first
    end

    def included_recipe
      Recipe.where(bakery: bakery, legacy_id: data[:recipeamt_ingredientid]).first
    end
  end
end
