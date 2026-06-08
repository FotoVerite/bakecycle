# frozen_string_literal: true

class AddInactiveToIngredientsAndProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :ingredients, :inactive, :boolean, default: false
    add_column :products, :inactive, :boolean, default: false
  end
end
