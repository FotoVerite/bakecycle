class AddProductionPermissionToUser < ActiveRecord::Migration
  def up
    add_column :users, :production_permission, :string

    User.connection.execute <<-SQL
      UPDATE users
      SET production_permission = 'manage'
      WHERE production_permission IS null
    SQL

    change_column :users, :production_permission, :string, null: false, default: "none"
  end

  def down
    remove_column :users, :production_permission
  end
end
