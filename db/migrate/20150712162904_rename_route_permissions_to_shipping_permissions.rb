class RenameRoutePermissionsToShippingPermissions < ActiveRecord::Migration
  def change
    rename_column :users, :route_permission, :shipping_permission
  end
end
