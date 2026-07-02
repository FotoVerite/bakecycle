# frozen_string_literal: true

class CreateProductTotalsSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :product_totals_snapshots do |t|
      t.integer :bakery_id, null: false
      t.string :source, null: false
      t.string :label, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.timestamps

      t.index %i[bakery_id label created_at]
      t.index :created_at
    end
    add_foreign_key :product_totals_snapshots, :bakeries

    create_table :product_totals_snapshot_rows do |t|
      t.bigint :snapshot_id, null: false
      t.date :delivery_date, null: false
      # product_id has no FK on purpose: rows must survive product deletion,
      # which is also why product_name is denormalized (same pattern as
      # shipment_items).
      t.integer :product_id, null: false
      t.string :product_name, null: false
      t.integer :quantity, null: false, default: 0

      t.index %i[snapshot_id delivery_date]
    end
    add_foreign_key :product_totals_snapshot_rows, :product_totals_snapshots, column: :snapshot_id
  end
end
