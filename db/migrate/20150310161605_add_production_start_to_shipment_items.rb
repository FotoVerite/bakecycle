class AddProductionStartToShipmentItems < ActiveRecord::Migration
  def change
    add_column :shipment_items, :production_start, :date, null: false, default: Date.today
    change_column_default(:shipment_items, :production_start, nil)
  end
end
