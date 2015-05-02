class CacheTotalLeadDays < ActiveRecord::Migration
  def change
    add_column :shipment_items, :product_total_lead_days, :integer

    # Save to trigger an update to product info
    ShipmentItem.find_each do |shipment_item|
      shipment_item.product = Product.find_by!(id: shipment_item.product_id)
      shipment_item.save!
    end

    change_column :shipment_items, :product_total_lead_days, :integer, null: false
  end
end
