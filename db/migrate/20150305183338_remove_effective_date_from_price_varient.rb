class RemoveEffectiveDateFromPriceVarient < ActiveRecord::Migration
  def up
    remove_index(:price_varients, name: "unique_price_varient")
    remove_column :price_varients, :effective_date
    add_index :price_varients, %i(product_id quantity), unique: true, name: "unique_price_varient_quantity"
    change_column :price_varients, :quantity, :integer, null: false
  end

  def down
    remove_index :price_varients, name: "unique_price_varient_quantity"
    add_column :price_varients, :effective_date, :date
    add_index :price_varients, %i(product_id quantity effective_date), unique: true, name: "unique_price_varient"
  end
end
