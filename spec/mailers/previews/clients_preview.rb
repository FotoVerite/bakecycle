# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/clients
class ClientsPreview < ActionMailer::Preview
  def invoice
    ClientsMailer.send_invoice(Shipment.last)
  end
end
