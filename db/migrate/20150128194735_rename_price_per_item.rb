class RenamePricePerItem < ActiveRecord::Migration
  def change
    rename_column :shipment_items, :price_per_item, :product_price
  end
end
