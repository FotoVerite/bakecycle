class DailyProductionRun < ActiveRecord::Migration
  def change
    change_column :production_runs, :date, :date
    add_index :production_runs, %i[bakery_id date]
  end
end
