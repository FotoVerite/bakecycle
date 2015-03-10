class EditDeliveryFeeFromClient < ActiveRecord::Migration
  def up
    remove_column :clients, :charge_delivery_fee
    add_column :clients, :delivery_fee_option, :integer
  end

  def down
    add_column :clients, :charge_delivery_fee, :boolean, default: false
    remove_column :clients, :delivery_fee_option
  end
end
