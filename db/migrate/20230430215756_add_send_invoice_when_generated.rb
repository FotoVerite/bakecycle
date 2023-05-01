class AddSendInvoiceWhenGenerated < ActiveRecord::Migration[5.1]
  def change
    add_column :clients, :send_shipment_when_generated, :boolean, default: false
    add_column :shipments, :sent, :boolean, default: false
  end
end
