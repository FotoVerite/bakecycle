# frozen_string_literal: true

class CreateVendors < ActiveRecord::Migration[5.1]
  def change
    unless table_exists? "vendors"
      create_table :vendors do |t|
        t.belongs_to :bakery
        t.string :name
        t.timestamps null: false
      end

      Vendor.create(bakery_id: 1, name: "L'epicerie")
      Vendor.create(bakery_id: 1, name: "Baldor")
    end
  end
end
