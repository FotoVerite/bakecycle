class AddProductPermissionToUser < ActiveRecord::Migration
  def change
    add_column :users, :product_permission, :string, null: false, default: 'none'
    User.where.not(bakery: nil).update_all(product_permission: 'manage')
  end
end
