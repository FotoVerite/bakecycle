class AddUniquenessBakeryScopesToModels < ActiveRecord::Migration
  def change
    remove_index :clients, :name
    add_index :clients, [:name, :bakery_id], unique: true

    remove_index :ingredients, :name
    add_index :ingredients, [:name, :bakery_id], unique: true

    remove_index :products, :name
    add_index :products, [:name, :bakery_id], unique: true

    remove_index :recipes, :name
    add_index :recipes, [:name, :bakery_id], unique: true

    add_index :routes, [:name, :bakery_id], unique: true
  end
end
