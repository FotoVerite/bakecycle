class AddDeliveryFeeToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :delivery_fee, :decimal, default: 0.0, null: false
    change_column :shipment_items, :product_quantity, :integer, default: 0, null: false
  end
end
