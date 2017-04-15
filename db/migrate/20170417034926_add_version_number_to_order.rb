class AddVersionNumberToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :version_number, :integer, default: 0
    add_reference :orders, :created_by_user, index: true
    add_reference :orders, :last_updated_by_user, index: true
  end
end
