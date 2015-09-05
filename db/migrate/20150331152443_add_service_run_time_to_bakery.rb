class AddServiceRunTimeToBakery < ActiveRecord::Migration
  def change
    add_column :bakeries, :kickoff_time, :time
    Bakery.update_all(kickoff_time: Chronic.parse("2 pm"))
    add_column :bakeries, :last_kickoff, :datetime
    change_column :bakeries, :kickoff_time, :time, null: false
  end
end
