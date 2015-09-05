class AddBakeryPermissionToUser < ActiveRecord::Migration
  def change
    add_column :users, :bakery_permission, :string, null: false, default: "none"
    User.where.not(bakery: nil).update_all(bakery_permission: "manage")
  end
end
