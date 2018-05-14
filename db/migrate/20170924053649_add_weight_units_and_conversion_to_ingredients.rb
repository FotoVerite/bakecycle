class AddWeightUnitsAndConversionToIngredients < ActiveRecord::Migration[5.1]
  def change
    add_column :ingredients, :weight_unit, :string, default: "grams"
    add_column :ingredients, :conversion, :decimal, default: 1
  end
end
