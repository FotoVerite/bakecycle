class AddWeightUnitsAndConversionToIngredients < ActiveRecord::Migration
  def change
    add_column :ingredients, :weight_unit, :string, default: "grams"
    add_column :ingredients, :conversion, :decimal, default: 1
  end
end
