class AddDeliverFeeInfoToClient < ActiveRecord::Migration
  def change
    add_column :clients, :charge_delivery_fee, :boolean, default: false
    add_column :clients, :delivery_minimum, :decimal, default: 0.0, null: false
    add_column :clients, :delivery_fee, :decimal, default: 0.0, null: false
  end
end
