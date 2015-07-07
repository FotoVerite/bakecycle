class AddOrderIdToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :order_id, :integer
  end
end
