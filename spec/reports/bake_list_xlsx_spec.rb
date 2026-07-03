# frozen_string_literal: true

require "rails_helper"

describe BakeListXlsx do
  let(:bakery) { create(:bakery) }
  let(:bake_date) { Date.new(2026, 6, 3) } # a Wednesday

  it "builds retail, wholesale, pull/prep, and viennoiserie rows" do
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie", bake_lead_days: 0,
      pieces_per_tray: 20)
    baguette = create(:product, bakery: bakery, name: "Baguette", product_type: "bread", bake_lead_days: 1)
    frozen_dough = create(:product, bakery: bakery, name: "Frozen Dough", on_pull_list: true, bake_lead_days: nil)

    retail_client = create(:client, bakery: bakery, bake_channel: "retail")
    wholesale_client = create(:client, bakery: bakery, bake_channel: "wholesale")

    retail_order = create(:order, bakery: bakery, client: retail_client, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: retail_order, product: croissant, daily_item_count: 0, wednesday: 40)
    create(:order_item, bakery: bakery, order: retail_order, product: frozen_dough, daily_item_count: 0, wednesday: 6)

    wholesale_order = create(:order, bakery: bakery, client: wholesale_client, start_date: bake_date + 1.day,
      order_item_count: 0)
    create(:order_item, bakery: bakery, order: wholesale_order, product: baguette, daily_item_count: 0, thursday: 25)

    report = described_class.new(bakery, bake_date)

    expect(report.retail_rows).to eq([["Croissant", 40, "2 trays", nil, nil]])
    expect(report.wholesale_rows).to eq([["Baguette", 25, nil, nil, nil]])
    expect(report.pull_list_rows).to eq([["Frozen Dough", 6, nil, nil]])
    expect(report.viennoiserie_rows).to eq([["Croissant", 40, "2 trays"]])
  end

  it "generates a valid xlsx workbook" do
    create(:product, bakery: bakery, name: "Croissant", bake_lead_days: 0)

    workbook = described_class.new(bakery, bake_date).generate

    expect(workbook).to start_with("PK")
    expect(workbook).to include("sharedStrings.xml")
  end
end
