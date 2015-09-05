class AddDefaults < ActiveRecord::Migration
  def up
    Client.where(active: nil).update_all(active: true)
    Route.where(active: nil).update_all(active: true)
    change_column :clients, :active, :boolean, null: false
    change_column :routes, :active, :boolean, null: false
  end

  def down
    change_column :clients, :active, :boolean, null: true
    change_column :routes, :active, :boolean, null: true
  end
end
