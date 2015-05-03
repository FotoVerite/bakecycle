class DailyProductionRun < ActiveRecord::Migration
  def change
    change_column :production_runs, :date, :date
    add_index :production_runs, [:bakery_id, :date]
  end
end
