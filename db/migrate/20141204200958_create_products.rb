class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.integer :product_type
      t.decimal :weight
      t.integer :unit
      t.text :description
      t.decimal :extra_amount
      t.integer :motherdough_id
      t.integer :inclusion_id

      t.timestamps
    end

    add_index :products, :name, unique: true
  end
end
