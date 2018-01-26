class AddAlertToOrderAndClients < ActiveRecord::Migration
  def change
    add_column :clients, :alert, :boolean, default: false
    add_column :orders, :alert, :boolean, default: false
  end
end
