class RenameProductPricesToPriceVarients < ActiveRecord::Migration
  def change
    rename_table :product_prices, :price_varients
  end
end
