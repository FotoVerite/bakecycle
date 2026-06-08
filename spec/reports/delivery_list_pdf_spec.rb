# frozen_string_literal: true

require "rails_helper"

describe DeliveryListPdf do
  let(:bakery) { create(:bakery) }
  let(:today) { Time.zone.today }

  it "renders client names, route, addresses, and date as parseable text" do
    route = create(:route, bakery: bakery, name: "Dawn Route")
    client = create(
      :client,
      bakery: bakery,
      name: "The Bread Shop",
      delivery_address_street_1: "42 Baker Street",
      delivery_address_city: "Brooklyn",
      delivery_address_state: "NY",
      delivery_address_zipcode: "11201"
    )
    shipment = create(:shipment, bakery: bakery, route: route, client: client, date: today)
    create(:shipment_item, bakery: bakery, shipment: shipment)

    text = pdf_text(DeliveryListPdf.new(bakery, today).render)

    expect(text).to include("Client Delivery List")
    expect(text).to include("Dawn Route")
    expect(text).to include("The Bread Shop")
    expect(text).to include("42 Baker Street")
  end

  it "renders client notes row when client has notes" do
    route = create(:route, bakery: bakery)
    client = create(:client, bakery: bakery, name: "VIP Cafe", notes: "Ring doorbell twice")
    shipment = create(:shipment, bakery: bakery, route: route, client: client, date: today)
    create(:shipment_item, bakery: bakery, shipment: shipment)

    text = pdf_text(DeliveryListPdf.new(bakery, today).render)

    expect(text).to include("Ring doorbell twice")
  end

  it "renders without error when there are no shipments" do
    pdf = DeliveryListPdf.new(bakery, today)
    expect(pdf.render).to_not be_nil
  end
end
