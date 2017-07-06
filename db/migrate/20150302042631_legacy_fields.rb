class LegacyFields < ActiveRecord::Migration
  def change
    add_column :clients, :legacy_id, :string
    add_index :clients, %i[legacy_id bakery_id], unique: true
  end
end
