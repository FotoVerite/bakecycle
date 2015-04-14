class AddNotNulls < ActiveRecord::Migration
  def change
    change_column :products, :name, :string, null: false
    change_column :products, :product_type, :integer, null: false

    Product.where(weight: nil).update_all(weight: 0)
    change_column :products, :weight, :decimal, null: false

    Product.where(unit: nil).update_all(unit: Product.units[:g])
    change_column :products, :unit, :integer, null: false

    Product.where(base_price: nil).update_all(base_price: 0)
    change_column :products, :base_price, :decimal, null: false
  end
end
