class AddPrintInvoiceToClients < ActiveRecord::Migration
  def change
    add_column :clients, :print_invoice, :boolean, default: true
  end
end
