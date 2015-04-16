class RecipeCollection < Set
  def find_or_create(recipe)
    recipe_data = detect { |data| data.recipe == recipe } || RecipeRunData.new(recipe)
    add(recipe_data)
    recipe_data
  end
end
