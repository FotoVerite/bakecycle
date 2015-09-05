class AddUserPersmissionToUser < ActiveRecord::Migration
  def change
    add_column :users, :user_permission, :string, null: false, default: "none"
    User.where.not(bakery: nil).update_all(user_permission: "manage")
  end
end
