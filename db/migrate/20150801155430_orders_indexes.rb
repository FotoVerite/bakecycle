# frozen_string_literal: true

class OrdersIndexes < ActiveRecord::Migration
  def change
    change_column_null :orders, :start_date, false
  end
end
