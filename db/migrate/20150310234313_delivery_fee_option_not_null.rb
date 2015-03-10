class DeliveryFeeOptionNotNull < ActiveRecord::Migration
  def change
    Client.update_all(delivery_fee_option: 0)
    change_column :clients, :delivery_fee_option, :integer, null: false
  end
end
