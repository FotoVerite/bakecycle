class RecipeCollection < Set
  def find_or_create(recipe, date)
    recipe_data = detect { |data| data.recipe == recipe } || RecipeRunData.new(recipe, date)
    add(recipe_data)
    recipe_data
  end
end
