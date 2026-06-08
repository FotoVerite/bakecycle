# frozen_string_literal: true

class AddEngagementStatusToclient < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :engagement_status, :integer, default: 0, null: false
  end
end
