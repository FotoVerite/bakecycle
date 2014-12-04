class CreateProductPrice < ActiveRecord::Migration
  def change
    create_table :product_prices do |t|
      t.belongs_to :product
      t.decimal :price, default: 0, null: false
      t.integer :quantity
      t.date :effective_date
      t.timestamps
    end
  end
end
