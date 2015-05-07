class AddUniqueValidationIndexToRunItems < ActiveRecord::Migration
  def change
    remove_index :run_items, [:production_run_id, :product_id]
    add_index :run_items, [:production_run_id, :product_id], unique: true
  end
end
