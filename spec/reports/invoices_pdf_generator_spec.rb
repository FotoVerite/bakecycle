# frozen_string_literal: true

require "rails_helper"

describe InvoicesPdfGenerator do
  let(:bakery) { create(:bakery, name: "Bien Cuit") }
  let(:search_form) do
    ShipmentSearchForm.new(
      client_id: [1, 2, 3],
      product_id: [4, 5, 6],
      date_from: Date.parse("30/12/2015"),
      date_to: Date.parse("30/12/2015"),
      sequence_number: ""
    )
  end
  let(:generator) { InvoicesPdfGenerator.new(bakery, search_form) }

  it "produces a file and a filename" do
    create_list(:shipment, 2, bakery: bakery)
    expect(generator.filename).to match(/Invoices.*\.pdf/)
    expect_any_instance_of(InvoicesPdf).to receive(:render).and_call_original
    expect(generator.generate).to_not be_nil
  end

  it "produces a file and filename when there are no shipments" do
    expect(generator.filename).to match(/Invoices.*\.pdf/)
    expect_any_instance_of(InvoicesPdf).to receive(:render).and_call_original
    expect(generator.generate).to_not be_nil
  end

  it "prepends the account name when the export contains one client" do
    client = create(:client, bakery: bakery, name: "Frisson Espresso - 47th")
    create(:shipment, bakery: bakery, client: client, date: Date.new(2026, 8, 17))
    create(:shipment, bakery: bakery, client: client, date: Date.new(2026, 8, 22))
    client_search = ShipmentSearchForm.new(
      client_id: [client.id], date_from: Date.new(2026, 8, 17), date_to: Date.new(2026, 8, 22)
    )

    expect(described_class.new(bakery, client_search).filename).to eq(
      "Frisson Espresso - 47th - bien-cuit-Invoices-2026-08-17-to-2026-08-22.pdf"
    )
  end

  it "keeps a generic filename when the export contains multiple clients" do
    create(:shipment, bakery: bakery, date: Date.new(2026, 8, 17))
    create(:shipment, bakery: bakery, date: Date.new(2026, 8, 22))
    unfiltered_search = ShipmentSearchForm.new(
      date_from: Date.new(2026, 8, 17), date_to: Date.new(2026, 8, 22)
    )

    expect(described_class.new(bakery, unfiltered_search).filename).to eq(
      "bien-cuit-Invoices-2026-08-17-to-2026-08-22.pdf"
    )
  end

  describe "global_id" do
    it "serializes and de-serializes" do
      expect(generator.id).to_not be_nil
      new_generator = InvoicesPdfGenerator.find(generator.id)
      expect(new_generator.bakery).to eq(generator.bakery)
      expect(new_generator.search.to_h).to eq(generator.search.to_h)
    end

    it "serializes and de-serialize via GlobalID" do
      id = generator.to_global_id.to_s
      new_generator = GlobalID::Locator.locate id
      expect(new_generator.bakery).to eq(generator.bakery)
      expect(new_generator.search.to_h).to eq(generator.search.to_h)
    end
  end
end
