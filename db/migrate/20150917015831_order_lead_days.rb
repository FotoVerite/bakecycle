class OrderLeadDays < ActiveRecord::Migration
  def change
    add_column :orders, :total_lead_days, :integer, null: true
    Order.update_all(total_lead_days: 0)
    change_column_null :orders, :total_lead_days, false
    change_column :orders, :note, :text, null: false, default: ""
  end
end
