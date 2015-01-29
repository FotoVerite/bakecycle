class RecipeDecorator < Draper::Decorator
  delegate_all

  def type
    recipe_type.humanize(capitalize: false).titleize
  end
end
