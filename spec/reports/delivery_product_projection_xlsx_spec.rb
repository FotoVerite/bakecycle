# frozen_string_literal: true

require "rails_helper"

describe DeliveryProductProjectionXlsx do
  let(:bakery) { create(:bakery) }
  let(:date) { Date.new(2026, 6, 3) }

  it "aggregates product totals without client details" do
    croissant = create(:product, bakery: bakery, name: "Croissant", pieces_per_tray: 60)
    baguette = create(:product, bakery: bakery, name: "Baguette")
    shipment = create(:shipment, bakery: bakery, date: date)
    other_date_shipment = create(:shipment, bakery: bakery, date: date + 1.day)

    create(:shipment_item, bakery: bakery, shipment: shipment, product: croissant, product_quantity: 300)
    create(:shipment_item, bakery: bakery, shipment: shipment, product: croissant, product_quantity: 222)
    create(:shipment_item, bakery: bakery, shipment: shipment, product: baguette, product_quantity: 12)
    create(:shipment_item, bakery: bakery, shipment: other_date_shipment, product: croissant, product_quantity: 60)

    rows = described_class.new(bakery, date).product_rows

    expect(rows).to eq([
      ["Baguette", 12, nil],
      ["Croissant", 522, "8 trays, 42 pieces"]
    ])
  end

  it "formats exact tray counts without a zero-piece remainder" do
    product = build(:product, pieces_per_tray: 60)
    report = described_class.new(bakery, date)

    expect(report.tray_count_for(product, 120)).to eq("2 trays")
  end

  it "generates an xlsx workbook" do
    shipment = create(:shipment, bakery: bakery, date: date)
    product = create(:product, bakery: bakery, name: "Croissant", pieces_per_tray: 60)
    create(:shipment_item, bakery: bakery, shipment: shipment, product: product, product_quantity: 61)

    workbook = described_class.new(bakery, date).generate

    expect(workbook).to start_with("PK")
    expect(workbook).to include("sharedStrings.xml")
  end
end
