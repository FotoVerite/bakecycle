# frozen_string_literal: true

class CreateProductGraphData < ActiveRecord::Migration[5.1]
  def change
    create_table :product_graph_data do |t|
      t.belongs_to :product
      t.belongs_to :bakery
      t.date :date
      t.integer :shipment_count
      t.integer :shipped
      t.decimal :amount
      t.timestamps
    end
    add_column :products, :graph_data, :json
  end
end
