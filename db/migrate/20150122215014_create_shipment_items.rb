class CreateShipmentItems < ActiveRecord::Migration
  def change
    create_table :shipment_items do |t|
      t.belongs_to :shipment
      t.belongs_to :product
      t.string :product_name
      t.integer :product_quantity
      t.decimal :price_per_item, default: 0.0, null: false
    end
  end
end
