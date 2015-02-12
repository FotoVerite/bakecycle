class AddSkuToShipmentItems < ActiveRecord::Migration
  def change
    add_column :shipment_items, :product_sku, :string
  end
end
