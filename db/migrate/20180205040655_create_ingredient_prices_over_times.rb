class CreateIngredientPricesOverTimes < ActiveRecord::Migration
  def change
  	drop_table :cost_over_times
  	remove_column :ingredients, :cost
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
