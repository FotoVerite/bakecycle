class AddTotalLeadDaysEverywhere < ActiveRecord::Migration
  def change
    add_column :recipes, :total_lead_days, :integer
    add_column :products, :total_lead_days, :integer
    add_column :order_items, :total_lead_days, :integer
    add_index :order_items, :total_lead_days

    Recipe.find_each(&:touch)
    Product.where(total_lead_days: nil).find_each(&:touch)
    OrderItem.where(total_lead_days: nil).find_each(&:touch)

    change_column_null :recipes, :total_lead_days, false
    change_column_null :products, :total_lead_days, false
    change_column_null :order_items, :total_lead_days, false
  end
end
