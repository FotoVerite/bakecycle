class CreateProductionRuns < ActiveRecord::Migration
  def change
    create_table :production_runs do |t|
      t.timestamps null: false
    end
  end
end
