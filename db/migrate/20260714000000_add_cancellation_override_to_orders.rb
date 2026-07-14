# frozen_string_literal: true

class AddCancellationOverrideToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :cancellation_override, :boolean, default: false, null: false
  end
end
