class AddAlertToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :alert, :boolean, default: false
  end
end
