class AddIndexUniquenessToPriceVarients < ActiveRecord::Migration
  def change
    add_index :price_varients, [:product_id, :quantity, :effective_date], unique: true , name: "unique_price_varient"
  end
end
