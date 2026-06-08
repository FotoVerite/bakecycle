# frozen_string_literal: true

require "rails_helper"

describe InvoicesCsv do
  it "renders csv invoices from a collection of shipments" do
    shipment = build(:shipment)
    csv = InvoicesCsv.new([shipment]).generate
    expect(csv).to include(shipment.client_name)
    expect(csv).to include(shipment.invoice_number)
  end
end
