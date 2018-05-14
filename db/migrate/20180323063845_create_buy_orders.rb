class CreateBuyOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :buy_orders do |t|
      t.belongs_to :vendor, :ingredient, :bakery
      t.decimal "amount", default: "0.0", null: false
      t.timestamps
    end
  end
end
