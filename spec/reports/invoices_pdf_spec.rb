require "rails_helper"

describe InvoicesPdf do
  it "renders invoice numbers, addresses, line items, notes, and totals as parseable text" do
    bakery = create(:bakery, name: "Bakecycle Test Bakery")
    route = create(:route, bakery: bakery, name: "Morning Route")
    client = create(
      :client,
      bakery: bakery,
      name: "Corner Cafe",
      delivery_address_street_1: "123 Delivery Ave",
      delivery_address_city: "Brooklyn",
      delivery_address_state: "NY",
      delivery_address_zipcode: "11211",
      billing_address_street_1: "987 Billing Road",
      billing_address_city: "Queens",
      billing_address_state: "NY",
      billing_address_zipcode: "11385",
      billing_term: :net_15
    )
    product = create(
      :product,
      bakery: bakery,
      name: "Seeded Sourdough",
      product_type: :bread,
      base_price: 4.25,
      weight: 1,
      unit: :kg
    )
    shipment = create(
      :shipment,
      bakery: bakery,
      route: route,
      client: client,
      date: Date.new(2026, 6, 2),
      delivery_fee: 3.50,
      note: "Leave by the back door"
    )
    create(:shipment_item, bakery: bakery, shipment: shipment, product: product, product_quantity: 4, product_price: 4.25)

    text = pdf_text(InvoicesPdf.new(bakery, Shipment.where(id: shipment.id)).render)

    expect(text).to include("Invoice")
    expect(text).to include(shipment.invoice_number)
    expect(text).to include("Corner Cafe")
    expect(text).to include("123 Delivery Ave")
    expect(text).to include("987 Billing Road")
    expect(text).to include("Net 15")
    expect(text).to include("Seeded Sourdough")
    expect(text).to include("Bread")
    expect(text).to include("$4.25")
    expect(text).to include("$17.00")
    expect(text).to include("$3.50")
    expect(text).to include("$20.50")
    expect(text).to include("Leave by the back door")
  end

  it "renders PO number column when shipment has a po_number" do
    bakery = create(:bakery)
    route = create(:route, bakery: bakery)
    client = create(:client, bakery: bakery)
    shipment = create(:shipment, bakery: bakery, route: route, client: client, po_number: "PO-9988")
    create(:shipment_item, bakery: bakery, shipment: shipment)

    text = pdf_text(InvoicesPdf.new(bakery, Shipment.where(id: shipment.id)).render)

    expect(text).to include("PO Number")
    expect(text).to include("PO-9988")
  end

  it "renders multiple shipments without error" do
    bakery = create(:bakery)
    create_list(:shipment, 2, bakery: bakery)
    pdf = InvoicesPdf.new(bakery, bakery.shipments)
    expect(pdf.render).to_not be_nil
  end
end
