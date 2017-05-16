class AddInvoiceSequenceToClient < ActiveRecord::Migration
  def change
    add_column :clients, :sequence_number, :integer, default: 1
    add_column :shipments, :sequence_number, :integer
  end
end
