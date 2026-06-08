# frozen_string_literal: true

class UpdateIngredientColumns < ActiveRecord::Migration[5.1]
  def change
    add_column :ingredients, :cost_per_gram, :decimal
  end
end
