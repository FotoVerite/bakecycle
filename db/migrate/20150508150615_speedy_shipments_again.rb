class SpeedyShipmentsAgain < ActiveRecord::Migration
  def change
    add_index :shipments, %i[client_id route_id date]
    add_index :shipments, [:bakery_id]
    add_index :users, [:bakery_id]
    add_index :shipment_items, [:shipment_id]
    add_index :order_items, [:order_id]
    add_index(
      :recipe_items,
      %i[recipe_id inclusionable_type inclusionable_id],
      name: :index_recipe_items_on_recipe_id_and_inclusionable
    )
  end
end
