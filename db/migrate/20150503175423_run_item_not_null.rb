class RunItemNotNull < ActiveRecord::Migration
  def change
    change_column :run_items, :product_id, :integer, null: false
  end
end
