# frozen_string_literal: true

class AddLeadDaysOverride < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :lead_days_override, :integer, default: 1
  end
end
