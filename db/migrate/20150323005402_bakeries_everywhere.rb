class BakeriesEverywhere < ActiveRecord::Migration
  def change
    change_column :clients, :bakery_id, :integer, null: false
    change_column :ingredients, :bakery_id, :integer, null: false
    change_column :orders, :bakery_id, :integer, null: false
    change_column :products, :bakery_id, :integer, null: false
    change_column :recipes, :bakery_id, :integer, null: false
    change_column :routes, :bakery_id, :integer, null: false
    change_column :shipments, :bakery_id, :integer, null: false

    add_timestamps :clients
    add_timestamps :order_items
    add_timestamps :orders
    add_timestamps :routes
    add_timestamps :shipment_items
    add_timestamps :shipments
  end
end
