class AddCachedPriceToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :cached_price, :decimal
  end
end
