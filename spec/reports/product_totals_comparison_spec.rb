# frozen_string_literal: true

require "rails_helper"

describe ProductTotalsComparison do
  let(:bakery) { create(:bakery) }
  let(:date) { Date.new(2026, 6, 3) } # a Wednesday

  it "outer-joins the two sources and computes differences" do
    croissant = create(:product, bakery: bakery, name: "Croissant")
    baguette = create(:product, bakery: bakery, name: "Baguette")
    order = create(:order, bakery: bakery, start_date: date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: croissant, wednesday: 100)
    create(:order_item, bakery: bakery, order: order, product: baguette, wednesday: 12)
    shipment = create(:shipment, bakery: bakery, date: date)
    create(:shipment_item, bakery: bakery, shipment: shipment, product: croissant, product_quantity: 90)

    comparison = described_class.new(
      described_class.live(bakery, date, date, source: "order_projection"),
      described_class.live(bakery, date, date, source: "generated_invoices")
    )

    rows = comparison.rows.map { |r| [r.product_name, r.baseline_quantity, r.compare_quantity, r.difference] }
    expect(rows).to eq([
      ["Baguette", 12, 0, -12],
      ["Croissant", 100, 90, -10]
    ])
    expect(comparison.differing_rows.size).to eq(2)
  end

  it "treats matching quantities as non-differences" do
    croissant = create(:product, bakery: bakery, name: "Croissant")
    order = create(:order, bakery: bakery, start_date: date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: croissant, wednesday: 90)
    shipment = create(:shipment, bakery: bakery, date: date)
    create(:shipment_item, bakery: bakery, shipment: shipment, product: croissant, product_quantity: 90)

    comparison = described_class.new(
      described_class.live(bakery, date, date, source: "order_projection"),
      described_class.live(bakery, date, date, source: "generated_invoices")
    )

    expect(comparison.rows.size).to eq(1)
    expect(comparison.differing_rows).to be_empty
  end

  it "compares a snapshot against a live source" do
    croissant = create(:product, bakery: bakery, name: "Croissant")
    order = create(:order, bakery: bakery, start_date: date, order_item_count: 0)
    item = create(:order_item, bakery: bakery, order: order, product: croissant, wednesday: 100)
    snapshot = ProductTotalsSnapshot.capture!(
      bakery: bakery, start_date: date, end_date: date,
      source: "order_projection", label: "nightly"
    )
    item.update!(wednesday: 150) # the order mutates after capture

    comparison = described_class.new(
      described_class.from_snapshot(snapshot, date, date),
      described_class.live(bakery, date, date, source: "order_projection")
    )

    row = comparison.rows.first
    expect(row.baseline_quantity).to eq(100)
    expect(row.compare_quantity).to eq(150)
    expect(row.difference).to eq(50)
  end

  it "fills quiet days with zeros for charting" do
    croissant = create(:product, bakery: bakery, name: "Croissant")
    order = create(:order, bakery: bakery, start_date: date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: croissant, daily_item_count: 0, wednesday: 40)

    comparison = described_class.new(
      described_class.live(bakery, date, date + 1.day, source: "order_projection"),
      described_class.live(bakery, date, date + 1.day, source: "generated_invoices")
    )

    expect(comparison.totals_by_date(date..(date + 1.day))).to eq([
      [date, 40, 0],
      [date + 1.day, 0, 0]
    ])
  end
end
