class AddUniquenessBakeryScopesToModels < ActiveRecord::Migration
  def change
    remove_index :clients, :name
    add_index :clients, %i(name bakery_id), unique: true

    remove_index :ingredients, :name
    add_index :ingredients, %i(name bakery_id), unique: true

    remove_index :products, :name
    add_index :products, %i(name bakery_id), unique: true

    remove_index :recipes, :name
    add_index :recipes, %i(name bakery_id), unique: true

    add_index :routes, %i(name bakery_id), unique: true
  end
end
