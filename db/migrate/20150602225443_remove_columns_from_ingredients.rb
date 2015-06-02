class RemoveColumnsFromIngredients < ActiveRecord::Migration
  def change
    remove_column :ingredients, :ingredient_type
    remove_column :ingredients, :price
    remove_column :ingredients, :measure
    remove_column :ingredients, :unit
  end
end
