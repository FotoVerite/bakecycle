class FixClientsPriceVariantsFk < ActiveRecord::Migration
  def change
    remove_foreign_key :price_variants, :clients
    add_foreign_key :price_variants, :clients, on_delete: :cascade
  end
end
