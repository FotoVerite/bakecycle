# frozen_string_literal: true

class ClientsMailer < ApplicationMailer
  default from: "admin@bakecycle.com"
  layout "mailer"

  def send_invoice(shipment)
    @shipment = shipment
    generator = InvoicePdfGenerator.new(shipment.client.bakery, shipment)
    file = FakeFileIO.new(generator.filename, generator.generate)
    @file_name = generator.filename
    attachments[@file_name] = file.read
    mail to: shipment.client.accounts_payable_contact_email, subject: "Invoice #{@file_name}"
  end
end
