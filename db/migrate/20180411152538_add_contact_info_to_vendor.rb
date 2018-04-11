class AddContactInfoToVendor < ActiveRecord::Migration[5.1]
  def change
    add_column :vendors, :contact, :string
    add_column :vendors, :phone, :string
    add_column :vendors, :email, :string
  end
end
