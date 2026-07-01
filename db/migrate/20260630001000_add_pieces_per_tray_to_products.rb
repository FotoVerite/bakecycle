# frozen_string_literal: true

class AddPiecesPerTrayToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :pieces_per_tray, :integer
  end
end
