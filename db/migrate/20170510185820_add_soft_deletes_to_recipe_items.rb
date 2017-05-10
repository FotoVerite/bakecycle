class AddSoftDeletesToRecipeItems < ActiveRecord::Migration
  def change
    add_column :recipe_items, :removed, :integer, index: true, default: false
  end
end
