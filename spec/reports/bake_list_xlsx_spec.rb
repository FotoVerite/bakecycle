# frozen_string_literal: true

require "rails_helper"
require "zip"

describe BakeListXlsx do
  let(:bakery) { create(:bakery) }
  let(:bake_date) { Date.new(2026, 6, 3) } # a Wednesday

  it "builds sectioned retail, wholesale, pull/prep, and viennoiserie pick rows" do
    smith = create(:client, bakery: bakery, name: "Bien Cuit - Smith Street")
    franklin = create(:client, bakery: bakery, name: "Bien Cuit - Franklin")
    restaurant = create(:client, bakery: bakery, name: "Restaurant")

    baguette = create(:product, bakery: bakery, name: "Baguette", product_type: "bread", bake_lead_days: 0)
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                                 bake_lead_days: 1, pieces_per_tray: 20)
    cookie = create(:product, bakery: bakery, name: "Chocolate Chip Cookie", product_type: "cookie",
                              bake_lead_days: 1)
    frozen_dough = create(:product, bakery: bakery, name: "Frozen Dough", on_pull_list: true, bake_lead_days: nil)
    create(:bake_lead_day_variant, product: croissant, client: smith, bake_lead_days: 0)

    smith_order = create(:order, bakery: bakery, client: smith, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: smith_order, product: baguette, daily_item_count: 0, wednesday: 24)
    create(:order_item, bakery: bakery, order: smith_order, product: croissant, daily_item_count: 0, wednesday: 8)
    create(:order_item, bakery: bakery, order: smith_order, product: frozen_dough, daily_item_count: 0, wednesday: 6)

    franklin_order = create(:order, bakery: bakery, client: franklin, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: franklin_order, product: baguette, daily_item_count: 0, wednesday: 12)

    wholesale_order = create(
      :order,
      bakery: bakery,
      client: restaurant,
      start_date: bake_date + 1.day,
      order_item_count: 0
    )
    create(:order_item, bakery: bakery, order: wholesale_order, product: croissant, daily_item_count: 0, thursday: 22)
    create(:order_item, bakery: bakery, order: wholesale_order, product: cookie, daily_item_count: 0, thursday: 96)

    report = described_class.new(bakery, bake_date)

    expect(report.retail_sections.map { |section| section[:name] }).to eq(%w[Bread Viennoiserie])
    # Item, Total, Smith, Franklin, GCM
    expect(report.retail_rows).to eq(
      [
        ["Baguette", 36, 24, 12, 0],
        ["Croissant", 8, 8, 0, 0]
      ]
    )

    expect(report.wholesale_sections.map { |section| section[:name] }).to eq(%w[Cookie Viennoiserie])
    expect(report.wholesale_rows).to eq(
      [
        ["Chocolate Chip Cookie", 96, nil, nil],
        ["Croissant", 22, nil, nil]
      ]
    )

    expect(report.pull_list_rows).to eq([["Frozen Dough", 6, nil, nil]])
    expect(report.viennoiserie_rows).to eq(
      [["Croissant", 1, 10, 1, 2, nil, nil, 0, 8, nil, nil]]
    )
  end

  it "highlights tray-tracked products and adds a Roule subtotal on the wholesale sheet" do
    tray_tracked = create(:product, bakery: bakery, name: "Ham & Brie Croissant", product_type: "vienoisserie",
                                    bake_lead_days: 1, pieces_per_tray: 60)
    not_tray_tracked = create(:product, bakery: bakery, name: "Almond Croissant", product_type: "vienoisserie",
                                        bake_lead_days: 1)
    roule_cinnamon = create(:product, bakery: bakery, name: "Roule, Cinnamon", product_type: "vienoisserie",
                                      bake_lead_days: 1)
    roule_everything = create(:product, bakery: bakery, name: "Roule, Everything", product_type: "vienoisserie",
                                        bake_lead_days: 1)

    order = create(:order, bakery: bakery, start_date: bake_date + 1.day, order_item_count: 0)
    [[tray_tracked, 17], [not_tray_tracked, 5], [roule_cinnamon, 20], [roule_everything, 12]].each do |product, qty|
      create(:order_item, bakery: bakery, order: order, product: product, daily_item_count: 0, thursday: qty)
    end

    report = described_class.new(bakery, bake_date)

    expect(report.wholesale_rows).to eq(
      [
        ["Almond Croissant", 5, nil, nil],
        ["Ham & Brie Croissant", 17, nil, nil],
        ["Roule, Cinnamon", 20, nil, nil],
        ["Roule, Everything", 12, nil, nil],
        ["ROULE TOTAL", 32, nil, nil]
      ]
    )
  end

  it "builds other_rows with fixed Smith/Franklin/GCM/Retail/Blue Bottle/Wholesale columns" do
    smith = create(:client, bakery: bakery, name: "Bien Cuit - Smith Street")
    franklin = create(:client, bakery: bakery, name: "Bien Cuit - Franklin")
    gcm = create(:client, bakery: bakery, name: "Bien Cuit - Grand Central")
    blue_bottle = create(:client, bakery: bakery, name: "Blue Bottle Coffee Nomad")
    restaurant = create(:client, bakery: bakery, name: "Some Restaurant")
    blondie = create(:product, bakery: bakery, name: "Blondie", product_type: "other", bake_lead_days: 1)
    create(:bake_lead_day_variant, product: blondie, client: smith, bake_lead_days: 0)

    quantities = { smith => 12, franklin => 16, gcm => 18, blue_bottle => 82, restaurant => 4 }
    quantities.each do |client, quantity|
      lead_days = client == smith ? 0 : 1
      order = create(:order, bakery: bakery, client: client, start_date: bake_date + lead_days.days,
                             order_item_count: 0)
      day = lead_days.zero? ? :wednesday : :thursday
      create(:order_item, bakery: bakery, order: order, product: blondie, daily_item_count: 0, day => quantity)
    end

    report = described_class.new(bakery, bake_date)

    # Item, Total, Smith, Franklin, GCM, Retail (stores summed), Blue Bottle, Wholesale (total - retail)
    expect(report.other_rows).to eq([["Blondie", 132, 12, 16, 18, 46, 82, 86]])
  end

  it "shows a fixed Smith/Franklin/GCM zero instead of dropping a store's column on a quiet day" do
    smith = create(:client, bakery: bakery, name: "Bien Cuit - Smith Street")
    baguette = create(:product, bakery: bakery, name: "Baguette", product_type: "bread", bake_lead_days: 0)
    order = create(:order, bakery: bakery, client: smith, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: baguette, daily_item_count: 0, wednesday: 12)

    report = described_class.new(bakery, bake_date)

    # Franklin and GCM didn't order -- still present, as explicit 0s.
    expect(report.retail_rows).to eq([["Baguette", 12, 12, 0, 0]])
  end

  it "generates a valid xlsx workbook" do
    create(:product, bakery: bakery, name: "Croissant", bake_lead_days: 0)

    workbook = described_class.new(bakery, bake_date).generate

    expect(workbook).to start_with("PK")

    Zip::File.open_buffer(StringIO.new(workbook)) do |zip|
      expect(zip.find_entry("xl/sharedStrings.xml")).to be_present
      workbook_xml = zip.read("xl/workbook.xml")
      expect(workbook_xml).to include("Retail Bread")
      expect(workbook_xml).to include("Wholesale Bread")
      expect(workbook_xml).to include("Quiche &amp; Dessert")
      expect(workbook_xml).to include("Vienn Pick")
    end
  end
end
