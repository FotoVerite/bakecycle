class AddIngredientLegacyId < ActiveRecord::Migration
  def change
    add_column :ingredients, :legacy_id, :string
    add_index :ingredients, %i[legacy_id bakery_id], unique: true
  end
end
