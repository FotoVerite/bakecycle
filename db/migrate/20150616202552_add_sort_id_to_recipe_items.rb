class AddSortIdToRecipeItems < ActiveRecord::Migration
  def change
    add_column :recipe_items, :sort_id, :integer
  end
end
