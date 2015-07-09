class AddRoutePermissionToUser < ActiveRecord::Migration
  def change
    add_column :users, :route_permission, :string, null: false, default: 'none'
    User.where.not(bakery: nil).update_all(route_permission: 'manage')
  end
end
