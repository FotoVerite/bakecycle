class AddNotesToClients < ActiveRecord::Migration
  def change
    add_column :clients, :notes, :string
    add_column :shipments, :client_notes, :string
  end
end
