# frozen_string_literal: true

class CreateBakeLeadDayVariants < ActiveRecord::Migration[8.1]
  def change
    create_table :bake_lead_day_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.integer :bake_lead_days, null: false
      t.integer :removed, default: 0

      t.timestamps
    end
    add_index :bake_lead_day_variants, %i[product_id client_id], unique: true
  end
end
