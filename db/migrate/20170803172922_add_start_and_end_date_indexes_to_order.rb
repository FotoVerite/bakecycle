class AddStartAndEndDateIndexesToOrder < ActiveRecord::Migration
  def change
    add_index :orders, :start_date
    add_index :orders, :end_date
    add_index :orders, %i[start_date end_date]
    add_index :orders, :order_type
    add_index :shipments, [:order_id]
    add_index :shipments, %i[order_id date]
  end
end
