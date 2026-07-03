# frozen_string_literal: true

class AddBakeChannelToClients < ActiveRecord::Migration[8.1]
  def change
    add_column :clients, :bake_channel, :integer, default: 0, null: false
  end
end
