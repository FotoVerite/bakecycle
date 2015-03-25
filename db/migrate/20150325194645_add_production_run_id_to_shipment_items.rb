class AddProductionRunIdToShipmentItems < ActiveRecord::Migration
  def change
    add_column :shipment_items, :production_run_id, :integer
    add_index :shipment_items, :production_run_id
  end
end
