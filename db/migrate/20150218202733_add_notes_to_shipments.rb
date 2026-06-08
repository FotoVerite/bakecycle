# frozen_string_literal: true

class AddNotesToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :note, :string
  end
end
