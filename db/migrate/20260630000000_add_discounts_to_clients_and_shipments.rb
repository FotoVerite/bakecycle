# frozen_string_literal: true

class AddDiscountsToClientsAndShipments < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :default_discount_type, :integer
    add_column :clients, :default_discount_value, :decimal, precision: 10, scale: 2

    add_column :shipments, :discount_type, :integer
    add_column :shipments, :discount_value, :decimal, precision: 10, scale: 2
  end
end
