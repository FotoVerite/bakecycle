# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Nightly sign off", type: :request do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery) }
  let(:route)  { create(:route, bakery: bakery) }
  let(:date)   { Date.new(2026, 6, 3) }

  before { sign_in user }

  it "lists Sandwich and Tartine invoices in the Wholesale Sandwiches section" do
    client = create(:client, bakery: bakery, name: "Cafe Sandwich")
    shipment = create(:shipment, bakery: bakery, client: client, route: route, date: date)
    product = create(:product, bakery: bakery, product_type: :sandwich_and_tartine)
    create(:shipment_item, bakery: bakery, shipment: shipment, product: product)

    get nightly_sign_off_path(date: date.to_s)

    expect(response).to be_successful
    expect(response.body).to include("Wholesale Sandwiches")
    expect(response.body).to include("Cafe Sandwich")
    expect(response.body).to include("1 invoice")
  end

  it "does not list Internal-channel clients in the Wholesale Sandwiches section" do
    client = create(:client, bakery: bakery, name: "Internal Sandwiches", channel: "Internal")
    shipment = create(:shipment, bakery: bakery, client: client, route: route, date: date)
    product = create(:product, bakery: bakery, product_type: :sandwich_and_tartine)
    create(:shipment_item, bakery: bakery, shipment: shipment, product: product)

    get nightly_sign_off_path(date: date.to_s)

    expect(response).to be_successful
    expect(response.body).to include("No wholesale sandwich orders for this date.")
    expect(response.body).not_to include("Internal Sandwiches")
  end
end
