class AddWholesaleManagerToClient < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :wholesale_manager, :string
  end
end
