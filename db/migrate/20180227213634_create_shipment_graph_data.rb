# frozen_string_literal: true

class CreateShipmentGraphData < ActiveRecord::Migration[5.1]
  def change
    create_table :shipment_graph_data do |t|
      t.belongs_to :bakery
      t.integer :product_count
      t.decimal "amount", default: "0.0", null: false
      t.date :date
      t.timestamps
      t.index :date
    end
    add_column :bakeries, :graph_data, :json
  end
end
