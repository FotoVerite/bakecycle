class AddBatchReportToProducts < ActiveRecord::Migration
  def change
    add_column :products, :batch_recipe, :boolean, default: false
  end
end
