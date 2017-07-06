class AddOrdersIndex < ActiveRecord::Migration
  def change
    add_index :orders, %i[bakery_id start_date end_date]
    add_index :orders, [:bakery_id]
  end
end
