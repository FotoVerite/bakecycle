class AddProductionStartToShipmentItems < ActiveRecord::Migration
  def change
    add_column :shipment_items, :production_start, :date, null: false
  end
end
