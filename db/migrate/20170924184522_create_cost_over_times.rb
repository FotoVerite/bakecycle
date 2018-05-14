class CreateCostOverTimes < ActiveRecord::Migration[5.1]
  def change
    unless table_exists? :cost_over_times
      create_table :cost_over_times do |t|
        t.belongs_to :ingredient
        t.string :weight_unit
        t.decimal :conversion
        t.decimal :cost_per_unit
        t.decimal :cost_per_gram
        t.timestamps null: false
      end
    end
  end
end
