class CreatePublicClientUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :public_client_users do |t|
      t.string :first_name, :last_name, :email
      t.belongs_to :client, :bakery
      t.timestamps
    end
  end
end
