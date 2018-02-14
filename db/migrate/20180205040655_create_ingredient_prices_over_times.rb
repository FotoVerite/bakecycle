class CreateIngredientPricesOverTimes < ActiveRecord::Migration[5.1]
  def change
    drop_table :cost_over_times do |t|
    end
    remove_column :ingredients, :cost, :decimal
    unless table_exists? :ingredient_prices_over_times
      create_table :ingredient_prices_over_times do |t|
        t.belongs_to :ingredient, :vendor, :bakery
        t.string :weight_unit
        t.decimal :conversion
        t.decimal :cost_per_unit
        t.decimal :cost_per_gram
        t.timestamps null: false
      end
    end
  end
end
