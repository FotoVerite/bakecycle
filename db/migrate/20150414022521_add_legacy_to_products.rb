class AddLegacyToProducts < ActiveRecord::Migration
  def change
    add_column :products, :legacy_id, :string
    add_index :products, [:legacy_id, :bakery_id], unique: true
  end
end
