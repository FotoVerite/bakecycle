class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.belongs_to :bakery
      t.string :name
      t.timestamps null: false
    end

    Vendor.create(bakery_id: 1, name: "L'epicerie")
    Vendor.create(bakery_id: 1, name: "Baldor")
  end
end
