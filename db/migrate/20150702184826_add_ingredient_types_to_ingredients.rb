class AddIngredientTypesToIngredients < ActiveRecord::Migration
  def change
    add_column :ingredients, :ingredient_type, :string, null: false, default: 'other'
  end
end
