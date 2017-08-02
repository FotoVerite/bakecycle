class CreateRunItems < ActiveRecord::Migration
  def change
    create_table :run_items do |t|
      t.integer :production_run_id
      t.integer :product_id
      t.integer :total_quantity
      t.integer :order_quantity
      t.integer :overbake_quantity

      t.timestamps null: false
    end

    add_index :run_items, %i(production_run_id product_id)
  end
end
