class AddProductTypeToShipmentItemsAndAccountToBakeries < ActiveRecord::Migration
  def change
    add_column :shipment_items, :product_product_type, :string

    # Save to trigger an update to product info
    ShipmentItem.find_each do |shipment_item|
      shipment_item.product = Product.find_by!(id: shipment_item.product_id)
      shipment_item.save!
    end

    change_column :shipment_items, :product_product_type, :string, null: false

    add_column :bakeries, :quickbooks_account, :string
    Bakery.update_all(quickbooks_account: 'Sales:Sales - Wholesale')
    change_column :bakeries, :quickbooks_account, :string, null: false
  end
end
