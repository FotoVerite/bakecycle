# frozen_string_literal: true

require "rails_helper"

describe ProductTotalsDateRangeGenerator do
  it "has a stable export id and filename" do
    bakery = create(:bakery)
    date = Date.new(2026, 6, 3)
    generator = described_class.new(bakery, date)

    expect(generator.id).to eq("#{bakery.id}_2026-06-03_2026-06-13_order_projection_product_totals_date_range")
    expect(generator.filename).to eq("Order-Product-Totals-2026-06-03-to-2026-06-13.xlsx")
  end

  it "uses a distinct export id and filename for generated invoices" do
    bakery = create(:bakery)
    date = Date.new(2026, 6, 3)
    generator = described_class.new(bakery, date, end_date: date + 6.days, source: "generated_invoices")

    expect(generator.id).to eq("#{bakery.id}_2026-06-03_2026-06-09_generated_invoices_product_totals_date_range")
    expect(generator.filename).to eq("Created-Shipment-Product-Totals-2026-06-03-to-2026-06-09.xlsx")
  end

  it "adds common and report-specific Sentry attributes" do
    bakery = create(:bakery)
    date = Date.new(2026, 6, 3)
    generator = described_class.new(bakery, date, end_date: date + 6.days, source: "generated_invoices")

    expect(generator.sentry_report_attributes).to include(
      bakery_id: bakery.id,
      date: "2026-06-03",
      end_date: "2026-06-09",
      date_count: 7,
      source: "generated_invoices"
    )
  end

  it "finds a generator from its global id" do
    bakery = create(:bakery)

    generator = described_class.find("#{bakery.id}_2026-06-03_2026-06-09_order_projection_product_totals_date_range")

    expect(generator.end_date).to eq(Date.new(2026, 6, 9))
    expect(generator.source).to eq("order_projection")
    expect(generator.filename).to eq("Order-Product-Totals-2026-06-03-to-2026-06-09.xlsx")
  end

  it "finds old generator ids as order projections" do
    bakery = create(:bakery)

    generator = described_class.find("#{bakery.id}_2026-06-03_delivery_product_projection")

    expect(generator.end_date).to eq(Date.new(2026, 6, 13))
    expect(generator.source).to eq("order_projection")
    expect(generator.filename).to eq("Order-Product-Totals-2026-06-03-to-2026-06-13.xlsx")
  end
end
