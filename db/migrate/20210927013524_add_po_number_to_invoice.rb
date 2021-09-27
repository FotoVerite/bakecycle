class AddPoNumberToInvoice < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :po_number, :string
  end
end
