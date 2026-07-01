# frozen_string_literal: true

require "rails_helper"

describe ProductTotalsDateRangeXlsx do
  let(:bakery) { create(:bakery) }
  let(:date) { Date.new(2026, 6, 3) }

  it "projects product totals from active orders without creating or reading shipments" do
    croissant = create(:product, bakery: bakery, name: "Croissant", pieces_per_tray: 60)
    baguette = create(:product, bakery: bakery, name: "Baguette")
    order = create(:order, bakery: bakery, start_date: date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: croissant, wednesday: 300)
    create(:order_item, bakery: bakery, order: order, product: croissant, wednesday: 222)
    create(:order_item, bakery: bakery, order: order, product: baguette, wednesday: 12)
    shipment = create(:shipment, bakery: bakery, date: date)

    create(:shipment_item, bakery: bakery, shipment: shipment, product: croissant, product_quantity: 999)

    rows = described_class.new(bakery, date, end_date: date, source: "order_projection").product_rows

    expect(rows).to eq([
      ["2026-06-03", "Baguette", 12, nil],
      ["2026-06-03", "Croissant", 522, "8 trays, 42 pieces"]
    ])
  end

  it "projects through ten days out and excludes day eleven" do
    product = create(:product, bakery: bakery, name: "Croissant")
    day_ten = date + 10.days
    day_eleven = date + 11.days
    create(:order, bakery: bakery, start_date: day_ten, order_item_count: 0).tap do |order|
      create(:order_item, bakery: bakery, order: order, product: product, saturday: 15)
    end
    create(:order, bakery: bakery, start_date: day_eleven, order_item_count: 0).tap do |order|
      create(:order_item, bakery: bakery, order: order, product: product, sunday: 20)
    end

    rows = described_class.new(bakery, date, source: "order_projection").product_rows

    expect(rows).to eq([["2026-06-13", "Croissant", 15, nil]])
  end

  it "uses temporary orders instead of standing orders for the same client route and date" do
    product = create(:product, bakery: bakery, name: "Croissant")
    standing = create(:order, bakery: bakery, start_date: date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: standing, product: product, wednesday: 40)
    temporary = create(
      :temporary_order,
      bakery: bakery,
      client: standing.client,
      route: standing.route,
      start_date: date,
      order_item_count: 0
    )
    create(:order_item, bakery: bakery, order: temporary, product: product, wednesday: 7)

    rows = described_class.new(bakery, date, end_date: date, source: "order_projection").product_rows

    expect(rows).to eq([["2026-06-03", "Croissant", 7, nil]])
  end

  it "uses generated invoices when selected" do
    croissant = create(:product, bakery: bakery, name: "Croissant", pieces_per_tray: 60)
    order = create(:order, bakery: bakery, start_date: date, order_item_count: 0)
    shipment = create(:shipment, bakery: bakery, date: date)
    other_date_shipment = create(:shipment, bakery: bakery, date: date + 1.day)

    create(:order_item, bakery: bakery, order: order, product: croissant, wednesday: 500)
    create(:shipment_item, bakery: bakery, shipment: shipment, product: croissant, product_quantity: 61)
    create(:shipment_item, bakery: bakery, shipment: other_date_shipment, product: croissant, product_quantity: 60)

    rows = described_class.new(bakery, date, end_date: date, source: "generated_invoices").product_rows

    expect(rows).to eq([["2026-06-03", "Croissant", 61, "1 tray, 1 piece"]])
  end

  it "uses order projection for a short window when selected" do
    product = create(:product, bakery: bakery, name: "Croissant")
    order = create(:order, bakery: bakery, start_date: date, order_item_count: 0)
    shipment = create(:shipment, bakery: bakery, date: date)

    create(:order_item, bakery: bakery, order: order, product: product, wednesday: 8)
    create(:shipment_item, bakery: bakery, shipment: shipment, product: product, product_quantity: 20)

    rows = described_class.new(bakery, date, end_date: date, source: "order_projection").product_rows

    expect(rows).to eq([["2026-06-03", "Croissant", 8, nil]])
  end

  it "formats exact tray counts without a zero-piece remainder" do
    product = build(:product, pieces_per_tray: 60)
    report = described_class.new(bakery, date, source: "order_projection")

    expect(report.tray_count_for(product, 120)).to eq("2 trays")
  end

  it "generates an xlsx workbook" do
    product = create(:product, bakery: bakery, name: "Croissant", pieces_per_tray: 60)
    order = create(:order, bakery: bakery, start_date: date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: product, wednesday: 61)

    workbook = described_class.new(bakery, date, source: "order_projection").generate

    expect(workbook).to start_with("PK")
    expect(workbook).to include("sharedStrings.xml")
  end
end
