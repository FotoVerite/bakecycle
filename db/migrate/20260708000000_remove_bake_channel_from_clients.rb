# frozen_string_literal: true

class RemoveBakeChannelFromClients < ActiveRecord::Migration[8.1]
  def change
    remove_column :clients, :bake_channel, :integer, default: 0, null: false
  end
end
