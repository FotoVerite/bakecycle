class SortId < ActiveRecord::Migration
  def change
    change_column :recipe_items, :sort_id, :integer, null: false, default: 0
  end
end
