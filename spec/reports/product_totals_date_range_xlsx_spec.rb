# frozen_string_literal: true

require "rails_helper"

describe ProductTotalsDateRangeXlsx do
  let(:bakery) { create(:bakery) }
  let(:date) { Date.new(2026, 6, 3) } # a Wednesday

  it "pivots products into rows and dates into columns, grouped by product type with subtotals" do
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "bread", pieces_per_tray: 60)
    baguette = create(:product, bakery: bakery, name: "Baguette", product_type: "bread")
    cookie = create(:product, bakery: bakery, name: "Chocolate Chip", product_type: "cookie")

    order = create(:order, bakery: bakery, start_date: date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: croissant, daily_item_count: 0, wednesday: 300, thursday: 100)
    create(:order_item, bakery: bakery, order: order, product: baguette, daily_item_count: 0, wednesday: 12)
    create(:order_item, bakery: bakery, order: order, product: cookie, daily_item_count: 0, wednesday: 40)

    report = described_class.new(bakery, date, end_date: date + 1.day, source: "order_projection")

    expect(report.header_row).to eq(["Product", "6/3/26", "6/4/26", "Grand Total"])
    expect(report.grouped_rows).to eq([
      {
        label: "Bread",
        rows: [
          ["Baguette", 12, 0, 12],
          ["Croissant", 300, 100, 400]
        ],
        subtotal: ["Subtotal", 312, 100, 412]
      },
      {
        label: "Cookie",
        rows: [["Chocolate Chip", 40, 0, 40]],
        subtotal: ["Subtotal", 40, 0, 40]
      }
    ])
  end

  it "orders product type groups by the model's own enum order, not alphabetically" do
    cookie = create(:product, bakery: bakery, name: "Snap", product_type: "cookie")
    bread = create(:product, bakery: bakery, name: "Boule", product_type: "bread")
    order = create(:order, bakery: bakery, start_date: date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: cookie, daily_item_count: 0, wednesday: 5)
    create(:order_item, bakery: bakery, order: order, product: bread, daily_item_count: 0, wednesday: 5)

    report = described_class.new(bakery, date, end_date: date, source: "order_projection")

    expect(report.grouped_rows.map { |group| group[:label] }).to eq(%w[Bread Cookie])
  end

  it "projects through ten days out and excludes day eleven" do
    product = create(:product, bakery: bakery, name: "Croissant", product_type: "bread")
    day_ten = date + 10.days
    day_eleven = date + 11.days
    create(:order, bakery: bakery, start_date: day_ten, order_item_count: 0).tap do |order|
      create(:order_item, bakery: bakery, order: order, product: product, daily_item_count: 0, saturday: 15)
    end
    create(:order, bakery: bakery, start_date: day_eleven, order_item_count: 0).tap do |order|
      create(:order_item, bakery: bakery, order: order, product: product, daily_item_count: 0, sunday: 20)
    end

    report = described_class.new(bakery, date, source: "order_projection")

    expect(report.grouped_rows.first[:rows]).to eq([["Croissant", *([0] * 10), 15, 15]])
  end

  it "uses generated invoices when selected" do
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "bread")
    order = create(:order, bakery: bakery, start_date: date, order_item_count: 0)
    shipment = create(:shipment, bakery: bakery, date: date)
    other_date_shipment = create(:shipment, bakery: bakery, date: date + 1.day)

    create(:order_item, bakery: bakery, order: order, product: croissant, daily_item_count: 0, wednesday: 500)
    create(:shipment_item, bakery: bakery, shipment: shipment, product: croissant, product_quantity: 61)
    create(:shipment_item, bakery: bakery, shipment: other_date_shipment, product: croissant, product_quantity: 60)

    report = described_class.new(bakery, date, end_date: date, source: "generated_invoices")

    expect(report.grouped_rows.first[:rows]).to eq([["Croissant", 61, 61]])
  end

  it "generates an xlsx workbook" do
    product = create(:product, bakery: bakery, name: "Croissant", product_type: "bread", pieces_per_tray: 60)
    order = create(:order, bakery: bakery, start_date: date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: product, daily_item_count: 0, wednesday: 61)

    workbook = described_class.new(bakery, date, source: "order_projection").generate

    expect(workbook).to start_with("PK")
    expect(workbook).to include("sharedStrings.xml")
  end
end
