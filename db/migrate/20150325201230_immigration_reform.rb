class ImmigrationReform < ActiveRecord::Migration
  def change
    add_foreign_key 'clients', 'bakeries', name: 'clients_bakery_id_fk'
    add_foreign_key 'ingredients', 'bakeries', name: 'ingredients_bakery_id_fk'
    add_foreign_key 'order_items', 'orders', name: 'order_items_order_id_fk', on_delete: :cascade
    add_foreign_key 'order_items', 'products', name: 'order_items_product_id_fk'
    add_foreign_key 'orders', 'bakeries', name: 'orders_bakery_id_fk'
    add_foreign_key 'orders', 'clients', name: 'orders_client_id_fk'
    add_foreign_key 'orders', 'routes', name: 'orders_route_id_fk'
    add_foreign_key 'price_varients', 'products', name: 'price_varients_product_id_fk', on_delete: :cascade
    add_foreign_key 'products', 'bakeries', name: 'products_bakery_id_fk'
    add_foreign_key 'products', 'recipes', column: 'inclusion_id', name: 'products_inclusion_id_fk'
    add_foreign_key 'products', 'recipes', column: 'motherdough_id', name: 'products_motherdough_id_fk'
    add_foreign_key 'recipe_items', 'recipes', name: 'recipe_items_recipe_id_fk', on_delete: :cascade
    add_foreign_key 'recipes', 'bakeries', name: 'recipes_bakery_id_fk'
    add_foreign_key 'routes', 'bakeries', name: 'routes_bakery_id_fk'
    add_foreign_key 'shipment_items', 'shipments', name: 'shipment_items_shipment_id_fk', on_delete: :cascade
    add_foreign_key 'shipments', 'bakeries', name: 'shipments_bakery_id_fk'
    add_foreign_key 'users', 'bakeries', name: 'users_bakery_id_fk'
  end
end
