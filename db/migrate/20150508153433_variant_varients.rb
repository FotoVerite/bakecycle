class VariantVarients < ActiveRecord::Migration
  def change
    rename_table :price_varients, :price_variants
    change_column_null :price_variants, :product_id, false
  end
end
