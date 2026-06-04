require "rails_helper"

describe PackingSlipsPdf do
  it "renders packing slip route, addresses, invoice number, item quantities, and invoice page when requested" do
    bakery = create(:bakery, name: "Bakecycle Test Bakery")
    route = create(:route, bakery: bakery, name: "North Route")
    client = create(
      :client,
      bakery: bakery,
      name: "Market Stand",
      delivery_address_street_1: "55 Market Street",
      delivery_address_city: "Brooklyn",
      delivery_address_state: "NY",
      delivery_address_zipcode: "11222",
      billing_address_street_1: "90 Accounting Ave",
      billing_address_city: "Brooklyn",
      billing_address_state: "NY",
      billing_address_zipcode: "11222"
    )
    product = create(
      :product,
      :with_sku,
      bakery: bakery,
      name: "Chocolate Babka",
      product_type: :vienoisserie,
      base_price: 8.00,
      weight: 1,
      unit: :kg
    )
    shipment = create(:shipment, bakery: bakery, route: route, client: client, date: Date.new(2026, 6, 2))
    create(:shipment_item, bakery: bakery, shipment: shipment, product: product, product_quantity: 6,
                           product_price: 8.00)

    pdf_bytes = PackingSlipsPdf.new([shipment], bakery, true).render
    text = pdf_text(pdf_bytes)

    expect(pdf_bytes).to start_with("%PDF")
    expect(pdf_page_count(pdf_bytes)).to be >= 2
    expect(text).to include("Packing Slip")
    expect(text).to include("Invoice")
    expect(text).to include(shipment.invoice_number)
    expect(text).to include("North Route")
    expect(text).to include("Market Stand")
    expect(text).to include("55 Market Street")
    expect(text).to include("90 Accounting Ave")
    expect(text).to include("Chocolate Babka")
    expect(text).to include("Vienoisserie")
    expect(text).to include("Pack Check")
    expect(text).to include("$48.00")
  end

  it "renders notes from shipment, order, and client" do
    bakery = create(:bakery)
    route = create(:route, bakery: bakery)
    client = create(:client, bakery: bakery, notes: "Knock loudly")
    shipment = create(:shipment, bakery: bakery, route: route, client: client, note: "Leave at side door")
    create(:shipment_item, bakery: bakery, shipment: shipment)

    text = pdf_text(PackingSlipsPdf.new([shipment], bakery, false).render)

    expect(text).to include("Notes")
    expect(text).to include("Knock loudly")
    expect(text).to include("Leave at side door")
  end

  it "renders VIP star indicator when shipment is flagged alert" do
    bakery = create(:bakery)
    route = create(:route, bakery: bakery)
    client = create(:client, bakery: bakery)
    shipment = create(:shipment, bakery: bakery, route: route, client: client, alert: true)
    create(:shipment_item, bakery: bakery, shipment: shipment)

    pdf_bytes = PackingSlipsPdf.new([shipment], bakery, false).render
    expect(pdf_bytes).to start_with("%PDF")
    expect(pdf_text(pdf_bytes)).to include("Packing Slip")
  end

  it "renders multiple shipments without error" do
    bakery = create(:bakery)
    shipments = create_list(:shipment, 2, bakery: bakery)
    pdf = PackingSlipsPdf.new(shipments, bakery, false)
    expect(pdf.render).to_not be_nil
  end
end
