# frozen_string_literal: true

class AddGroupAndChannelToClients < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :group, :string
    add_column :clients, :channel, :string
  end
end
