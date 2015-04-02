class AddDateToProductionRun < ActiveRecord::Migration
  def change
    add_column :production_runs, :date, :datetime, null: false
    add_column :production_runs, :bakery_id, :integer, null: false
    add_index :production_runs, :bakery_id
  end
end
