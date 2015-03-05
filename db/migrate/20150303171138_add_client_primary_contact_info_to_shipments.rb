class AddClientPrimaryContactInfoToShipments < ActiveRecord::Migration
  def change
    change_table :shipments do |t|
      t.string  :client_primary_contact_name
      t.string  :client_primary_contact_phone
    end
  end
end
