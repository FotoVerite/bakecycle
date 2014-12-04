class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.string :name
      t.decimal :price
      t.decimal :measure
      t.integer :unit
      t.integer :ingredient_type
      t.text :description

      t.timestamps
    end

    add_index :ingredients, :name, unique: true
  end
end
