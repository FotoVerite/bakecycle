# frozen_string_literal: true

class AddBakeListFieldsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :bake_lead_days, :integer, default: 1
    add_column :products, :on_pull_list, :boolean, default: false, null: false
  end
end
