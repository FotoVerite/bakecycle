# frozen_string_literal: true

class AddTempVipToClient < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :temp_vip, :boolean, default: false
  end
end
