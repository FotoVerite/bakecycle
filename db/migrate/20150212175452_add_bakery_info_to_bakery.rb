class AddBakeryInfoToBakery < ActiveRecord::Migration
  def change
    change_table :bakeries do |t|
      t.string  :email
      t.string  :phone_number
      t.string  :address_street_1
      t.string  :address_street_2
      t.string  :address_city
      t.string  :address_state
      t.string  :address_zipcode
      t.attachment :logo
    end
  end
end
