class OrderCliffnotes < ActiveRecord::Migration
  def change
    change_column :orders, :note, :text
    change_column :shipments, :note, :text
  end
end
