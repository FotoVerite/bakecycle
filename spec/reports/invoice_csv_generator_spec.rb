# frozen_string_literal: true

require "rails_helper"

describe InvoiceCsvGenerator do
  let(:bakery) { create(:bakery) }
  let(:client) { create(:client, bakery: bakery, name: "Jane's Café & Market") }
  let(:shipment) { create(:shipment, bakery: bakery, client: client) }
  let(:generator) { described_class.new(bakery, shipment) }

  it "prepends the client name to the filename" do
    expect(generator.filename).to eq(
      "Jane's Café & Market - #{bakery.name.parameterize}-Invoice-#{shipment.invoice_number}.csv"
    )
  end
end
