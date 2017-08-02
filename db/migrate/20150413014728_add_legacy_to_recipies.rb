class AddLegacyToRecipies < ActiveRecord::Migration
  def change
    add_column :recipes, :legacy_id, :string
    add_index :recipes, %i(legacy_id bakery_id), unique: true
  end
end
