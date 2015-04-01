class AddServiceRunTimeToBakery < ActiveRecord::Migration
  def change
    add_column :bakeries, :kickoff_time, :time, null: false
    add_column :bakeries, :last_kickoff, :datetime
  end
end
