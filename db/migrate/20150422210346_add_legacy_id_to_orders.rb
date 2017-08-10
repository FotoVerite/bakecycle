class AddLegacyIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :legacy_id, :integer
    add_index :orders, %i[legacy_id bakery_id], unique: true
  end
end
