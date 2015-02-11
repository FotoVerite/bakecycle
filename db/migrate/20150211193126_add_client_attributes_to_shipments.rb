class AddClientAttributesToShipments < ActiveRecord::Migration
  def change
    change_table :shipments do |t|
      t.string  :client_name
      t.string  :client_dba
      t.string  :client_billing_term
      t.string  :client_delivery_address_street_1
      t.string  :client_delivery_address_street_2
      t.string  :client_delivery_address_city
      t.string  :client_delivery_address_state
      t.string  :client_delivery_address_zipcode
      t.string  :client_billing_address_street_1
      t.string  :client_billing_address_street_2
      t.string  :client_billing_address_city
      t.string  :client_billing_address_state
      t.string  :client_billing_address_zipcode
      t.integer :client_billing_term_days
    end
  end
end
