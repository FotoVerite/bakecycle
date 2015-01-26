class RenameShipmentDate < ActiveRecord::Migration
  def change
    rename_column :shipments, :shipment_date, :date
  end
end
