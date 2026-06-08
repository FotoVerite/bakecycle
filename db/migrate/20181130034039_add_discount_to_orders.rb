# frozen_string_literal: true

class AddDiscountToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :discount, :decimal
    add_column :shipments, :discount, :decimal
  end
end
