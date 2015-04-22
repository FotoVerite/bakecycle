class AddLegacyIdToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :legacy_id, :integer
    add_index :routes, [:legacy_id, :bakery_id], unique: true
  end
end
