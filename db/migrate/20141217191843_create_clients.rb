class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name
      t.string :dba
      t.string :business_phone
      t.string :business_fax
      t.boolean :active
      t.string :delivery_address_street_1
      t.string :delivery_address_street_2
      t.string :delivery_address_city
      t.string :delivery_address_state
      t.string :delivery_address_zipcode
      t.string :billing_address_street_1
      t.string :billing_address_street_2
      t.string :billing_address_city
      t.string :billing_address_state
      t.string :billing_address_zipcode
      t.string :accounts_payable_contact_name
      t.string :accounts_payable_contact_phone
      t.string :accounts_payable_contact_email
      t.string :primary_contact_name
      t.string :primary_contact_phone
      t.string :primary_contact_email
      t.string :secondary_contact_name
      t.string :secondary_contact_phone
      t.string :secondary_contact_email
    end

    add_index :clients, :name, unique: true
    add_index :clients, :active
  end
end
