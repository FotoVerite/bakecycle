class AddProductTypeToShipmentItemsAndAccountToBakeries < ActiveRecord::Migration
  def change
    add_column :shipment_items, :product_product_type, :string

    ShipmentItem.find_each do |shipment_item|
      shipment_item.product_product_type = Product.find_by(id: shipment_item.product_id).product_type
      shipment_item.save!
    end

    change_column :shipment_items, :product_product_type, :string, null: false

    add_column :bakeries, :quickbooks_account, :string
    Bakery.update_all(quickbooks_account: 'Sales:Sales - Wholesale')
    change_column :bakeries, :quickbooks_account, :string, null: false
  end
end
