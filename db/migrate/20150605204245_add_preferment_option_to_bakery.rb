class AddPrefermentOptionToBakery < ActiveRecord::Migration
  def change
    add_column :bakeries, :group_preferments, :boolean, default: true
  end
end
