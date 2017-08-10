class RemoveColumnsFromIngredients < ActiveRecord::Migration
  def down
    remove_column :ingredients, :ingredient_type
    remove_column :ingredients, :price
    remove_column :ingredients, :measure
    remove_column :ingredients, :unit
  end

  def up; end
end
