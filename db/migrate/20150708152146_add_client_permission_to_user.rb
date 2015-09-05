class AddClientPermissionToUser < ActiveRecord::Migration
  def change
    add_column :users, :client_permission, :string, null: false, default: "none"
    User.where.not(bakery: nil).update_all(client_permission: "manage")
  end
end
