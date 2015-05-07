class RecipeItemsRecipeNotNull < ActiveRecord::Migration
  def change
    change_column_null :recipe_items, :recipe_id, false
  end
end
