class AddCostCurrentAmountAndVendorIdToIngredients < ActiveRecord::Migration
  def change
    add_column :ingredients, :vendor_id, :integer
    add_column :ingredients, :cost, :decimal, default: 0.0, null: false
    add_column :ingredients, :current_amount, :decimal, default: 0.0, null: false
  end
end
