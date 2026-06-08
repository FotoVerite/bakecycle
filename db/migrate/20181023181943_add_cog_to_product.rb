# frozen_string_literal: true

class AddCogToProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :cog, :decimal
  end
end
