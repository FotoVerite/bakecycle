class IngredientDecorator < Draper::Decorator
  delegate_all

  def ingredient_types_select
    Ingredient::INGREDIENT_TYPES.map { |type| [type.humanize, type] }
  end
end
