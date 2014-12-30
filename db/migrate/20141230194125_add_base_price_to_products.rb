class AddBasePriceToProducts < ActiveRecord::Migration
  def change
    add_column :products, :base_price, :decimal
  end
end
