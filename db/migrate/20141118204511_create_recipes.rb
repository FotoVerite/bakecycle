class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :name
      t.text :note
      t.decimal :mix_size
      t.integer :mix_size_unit
      t.integer :recipe_type
      t.integer :lead_days, default: 0, null: false

      t.timestamps
    end
    add_index :recipes, :name, unique: true
  end
end
