# frozen_string_literal: true

require "rails_helper"

describe InvoicesCsv do
  it "renders csv invoices from a collection of shipments" do
    shipment = build(:shipment, discount_type: "percentage", discount_value: 10)
    shipment.shipment_items = build_list(:shipment_item, 1, product_quantity: 5, product_price: 2.0)
    csv = InvoicesCsv.new([shipment]).generate
    rows = CSV.parse(csv)

    expect(csv).to include(shipment.client_name)
    expect(csv).to include(shipment.invoice_number)
    expect(rows.first).to include("Invoice discount")
    expect(rows.second[9].to_d).to eq(1.0)
  end
end
