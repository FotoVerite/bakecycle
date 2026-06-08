# frozen_string_literal: true

class ChangeNotNullClients < ActiveRecord::Migration
  def change
    change_column_null :orders, :client_id, false
  end
end
