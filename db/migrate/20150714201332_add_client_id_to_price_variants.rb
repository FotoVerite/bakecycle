class AddClientIdToPriceVariants < ActiveRecord::Migration
  def change
    add_reference :price_variants, :client
    add_index :price_variants, :product_id
    add_index :price_variants, [:quantity, :product_id, :client_id], unique: true
    remove_index :price_variants, column: :quantity, name: "unique_price_varient_quantity"

    add_foreign_key "price_variants", "clients"
  end
end
