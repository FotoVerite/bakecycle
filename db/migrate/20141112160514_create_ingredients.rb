class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.string :name
      t.decimal :price, precision: 7, scale: 2
      t.decimal :measure, precision: 7, scale: 3
      t.integer :unit
      t.text :description

      t.timestamps
    end

    add_index :ingredients, :name, unique: true
  end
end
