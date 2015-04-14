module LegacyImporter
  class RecipeItemImporter
    attr_reader :data, :bakery

    def initialize(bakery, legacy_recipe_item)
      @bakery = bakery
      @data = legacy_recipe_item
    end

    def import!
      return SkippedRecipeItem.new(data) if skip?
      RecipeItem.where(
        recipe_id: recipe.try(:id),
        inclusionable: ingredient || included_recipe
      )
        .first_or_initialize
        .tap { |item| item.update(bakers_percentage: data[:recipeamt_bakerspct]) }
    end

    class SkippedRecipeItem < SkippedObject
    end

    private

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
