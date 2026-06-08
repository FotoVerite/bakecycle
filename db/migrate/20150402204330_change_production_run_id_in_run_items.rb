# frozen_string_literal: true

class ChangeProductionRunIdInRunItems < ActiveRecord::Migration
  def change
    change_column :run_items, :production_run_id, :integer, null: false
  end
end
