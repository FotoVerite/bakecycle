class AddSoftDeletesToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :removed, :integer, index: true, default: false
  end
end
