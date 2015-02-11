class AddAutoGenerateToShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :auto_generated, :boolean, default: false, null: false
  end
end
