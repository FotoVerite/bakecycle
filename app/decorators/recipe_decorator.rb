class RecipeDecorator < Draper::Decorator
  delegate_all

  def type
    recipe_type.humanize(capitalize: false).titleize
  end

  def available_inclusions
    h.item_finder.inclusionables.delete_if do |item|
      item[1] == "#{object.id}-#{object.class.name}"
    end
  end
end
