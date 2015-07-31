require "rails_helper"

describe InvoicesCsv do
  it "renders csv invoices from a collection of shipments" do
    bakery = build_stubbed(:bakery)
    client = build_stubbed(:client, name: "Mando", bakery: bakery)
    route = build_stubbed(:route, bakery: bakery)
    shipment = build_stubbed(:shipment, client: client, bakery: bakery, route: route)
    csv = InvoicesCsv.new([shipment.decorate]).generate
    expect(csv).to include("Mando")
    expect(csv).to include(shipment.invoice_number)
  end
end
