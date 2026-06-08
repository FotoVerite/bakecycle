# frozen_string_literal: true

class AddCachedPriceToShipment < ActiveRecord::Migration[5.1]
  # NOTE
  def change
    add_column :shipments, :cached_price, :decimal
  end
end
