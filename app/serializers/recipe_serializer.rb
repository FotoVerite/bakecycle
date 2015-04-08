class RecipeSerializer < ActiveModel::Serializer
  attributes :id, :recipe_type

  def recipe_type
    object.recipe_type || ''
  end
end
