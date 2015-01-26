class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.belongs_to :client
      t.belongs_to :route
      t.date :shipment_date
      t.date :payment_due_date
    end
  end
end
