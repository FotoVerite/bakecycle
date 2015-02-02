class AddBakeryIdToModels < ActiveRecord::Migration
  def change
    add_column :shipments, :bakery_id, :integer
    add_column :recipes, :bakery_id, :integer
    add_column :clients, :bakery_id, :integer
    add_column :ingredients, :bakery_id, :integer
    add_column :products, :bakery_id, :integer
    add_column :orders, :bakery_id, :integer
    add_column :routes, :bakery_id, :integer
    add_column :users, :bakery_id, :integer
  end
end
