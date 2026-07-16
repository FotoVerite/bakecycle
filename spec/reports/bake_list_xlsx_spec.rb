# frozen_string_literal: true

require "rails_helper"
require "zip"

describe BakeListXlsx do
  let(:bakery) { create(:bakery) }
  let(:bake_date) { Date.new(2026, 6, 3) } # a Wednesday

  it "builds sectioned retail, wholesale, and viennoiserie pick rows" do
    smith = create(:client, bakery: bakery, name: "Bien Cuit - Smith Street")
    franklin = create(:client, bakery: bakery, name: "Bien Cuit - Franklin")
    restaurant = create(:client, bakery: bakery, name: "Restaurant")

    baguette = create(:product, bakery: bakery, name: "Baguette", product_type: "bread", bake_lead_days: 0)
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                                 bake_lead_days: 1, pieces_per_tray: 20, over_bake: 0)
    cookie = create(:product, bakery: bakery, name: "Chocolate Chip Cookie", product_type: "cookie",
                              bake_lead_days: 1, over_bake: 0)
    create(:bake_lead_day_variant, product: croissant, client: smith, bake_lead_days: 0)

    smith_order = create(:order, bakery: bakery, client: smith, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: smith_order, product: baguette, daily_item_count: 0, wednesday: 24)
    create(:order_item, bakery: bakery, order: smith_order, product: croissant, daily_item_count: 0, wednesday: 8)

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
    # Item, Total, Smith, Franklin (no Grand Central store column)
    expect(report.retail_rows).to eq(
      [
        ["Baguette", 36, 24, 12],
        ["Croissant", 8, 8, 0]
      ]
    )

    expect(report.wholesale_sections.map { |section| section[:name] }).to eq(%w[Cookie Viennoiserie])
    expect(report.wholesale_rows).to eq(
      [
        ["Chocolate Chip Cookie", 96, nil, nil],
        ["Croissant", 22, nil, nil]
      ]
    )

    expect(report.viennoiserie_rows).to eq(
      [
        ["Croissant", 1, 10, 1, 2, nil, nil, 0, 8, nil, nil],
        ["Pate Fermentee", 8, nil, nil, nil, nil, nil, nil, nil, nil, nil]
      ]
    )
  end

  it "adds a Roule subtotal on the wholesale sheet" do
    ham_brie = create(:product, bakery: bakery, name: "Ham & Brie Croissant", product_type: "vienoisserie",
                                bake_lead_days: 1, pieces_per_tray: 60, over_bake: 0)
    almond = create(:product, bakery: bakery, name: "Almond Croissant", product_type: "vienoisserie",
                              bake_lead_days: 1, over_bake: 0)
    roule_cinnamon = create(:product, bakery: bakery, name: "Roule, Cinnamon", product_type: "vienoisserie",
                                      bake_lead_days: 1, over_bake: 0)
    roule_everything = create(:product, bakery: bakery, name: "Roule, Everything", product_type: "vienoisserie",
                                        bake_lead_days: 1, over_bake: 0)

    order = create(:order, bakery: bakery, start_date: bake_date + 1.day, order_item_count: 0)
    [[ham_brie, 17], [almond, 5], [roule_cinnamon, 20], [roule_everything, 12]].each do |product, qty|
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

  it "adds a Roule subtotal on the retail sheet" do
    cinnamon = create(:product, bakery: bakery, name: "Roule, Cinnamon", product_type: "vienoisserie",
                                bake_lead_days: 0)
    everything = create(:product, bakery: bakery, name: "Roule, Everything", product_type: "vienoisserie",
                                  bake_lead_days: 0)
    order = create(:order, bakery: bakery, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: cinnamon, daily_item_count: 0, wednesday: 20)
    create(:order_item, bakery: bakery, order: order, product: everything, daily_item_count: 0, wednesday: 12)

    expect(described_class.new(bakery, bake_date).retail_rows).to eq(
      [
        ["Roule, Cinnamon", 20, 0, 0],
        ["Roule, Everything", 12, 0, 0],
        ["ROULE TOTAL", 32, nil, nil]
      ]
    )
  end

  it "collapses Roule flavors into one Vienn Pick row and appends a fixed Pate Fermentee tray row" do
    roule_cinnamon = create(:product, bakery: bakery, name: "Roule, Cinnamon", product_type: "vienoisserie",
                                      bake_lead_days: 1, pieces_per_tray: 120)
    roule_everything = create(:product, bakery: bakery, name: "Roule, Everything", product_type: "vienoisserie",
                                        bake_lead_days: 1, pieces_per_tray: 120)

    order = create(:order, bakery: bakery, start_date: bake_date + 1.day, order_item_count: 0)
    [[roule_cinnamon, 130], [roule_everything, 20]].each do |product, qty|
      create(:order_item, bakery: bakery, order: order, product: product, daily_item_count: 0, thursday: qty)
    end

    report = described_class.new(bakery, bake_date)

    # One "Roule" row (150 total = 1 tray of 120 + 30 pieces, all wholesale),
    # then the fixed 8-tray Pate Fermentee prep row. No per-flavor rows.
    expect(report.viennoiserie_rows).to eq(
      [
        ["Roule", 1, 30, 1, 30, nil, nil, 0, 0, nil, nil],
        ["Pate Fermentee", 8, nil, nil, nil, nil, nil, nil, nil, nil, nil]
      ]
    )
  end

  it "breaks Grand Central out on Pull Prep while keeping it in wholesale" do
    smith = create(:client, bakery: bakery, name: "Bien Cuit - Smith Street")
    franklin = create(:client, bakery: bakery, name: "Bien Cuit - Franklin")
    gcm = create(:client, bakery: bakery, name: "Bien Cuit - Grand Central")
    blue_bottle = create(:client, bakery: bakery, name: "Blue Bottle Coffee Nomad")
    restaurant = create(:client, bakery: bakery, name: "Some Restaurant")
    blondie = create(:product, bakery: bakery, name: "Blondie", product_type: "other", on_pull_list: true)

    quantities = { smith => 12, franklin => 16, gcm => 18, blue_bottle => 82, restaurant => 4 }
    quantities.each do |client, quantity|
      order = create(
        :order,
        bakery: bakery,
        client: client,
        start_date: bake_date + 1.day,
        order_item_count: 0
      )
      create(:order_item, bakery: bakery, order: order, product: blondie, daily_item_count: 0, thursday: quantity)
    end

    report = described_class.new(bakery, bake_date)

    # Item, Total, Smith, Franklin, Grand Central, Retail (Smith + Franklin),
    # Blue Bottle, Wholesale (total - retail, including Grand Central).
    expect(report.other_rows).to eq([["Blondie", 132, 12, 16, 18, 28, 82, 104]])
  end

  it "shows a fixed Smith/Franklin zero instead of dropping a store's column on a quiet day" do
    smith = create(:client, bakery: bakery, name: "Bien Cuit - Smith Street")
    baguette = create(:product, bakery: bakery, name: "Baguette", product_type: "bread", bake_lead_days: 0)
    order = create(:order, bakery: bakery, client: smith, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: baguette, daily_item_count: 0, wednesday: 12)

    report = described_class.new(bakery, bake_date)

    # Franklin didn't order -- still present, as an explicit 0.
    expect(report.retail_rows).to eq([["Baguette", 12, 12, 0]])
  end

  it "folds each product's overbake into the wholesale sheet total, sized against retail + wholesale combined" do
    smith = create(:client, bakery: bakery, name: "Bien Cuit - Smith Street")
    restaurant = create(:client, bakery: bakery, name: "Restaurant")
    # 25% overbake; retail via a Smith lead-0 override, wholesale via the restaurant.
    cookie = create(:product, bakery: bakery, name: "Cookie", product_type: "cookie",
                              bake_lead_days: 1, over_bake: 25)
    create(:bake_lead_day_variant, product: cookie, client: smith, bake_lead_days: 0)

    retail_order = create(:order, bakery: bakery, client: smith, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: retail_order, product: cookie, daily_item_count: 0, wednesday: 40)
    wholesale_order = create(:order, bakery: bakery, client: restaurant, start_date: bake_date + 1.day,
                                     order_item_count: 0)
    create(:order_item, bakery: bakery, order: wholesale_order, product: cookie, daily_item_count: 0, thursday: 100)

    report = described_class.new(bakery, bake_date)

    # It's one bake batch across both sheets (100 wholesale + 40 retail = 140), so the
    # margin covers the whole batch: ceil(140 * 25 / 100) = 35, added on top of the
    # wholesale-only 100. Retail itself stays order-only, no margin of its own.
    expect(report.wholesale_rows).to eq([["Cookie", 135, nil, nil]])
    expect(report.retail_rows).to eq([["Cookie", 40, 40, 0]])
  end

  it "sizes the overbake off wholesale alone when the product has no retail bake that day" do
    restaurant = create(:client, bakery: bakery, name: "Restaurant")
    cookie = create(:product, bakery: bakery, name: "Cookie", product_type: "cookie",
                              bake_lead_days: 1, over_bake: 25)
    wholesale_order = create(:order, bakery: bakery, client: restaurant, start_date: bake_date + 1.day,
                                     order_item_count: 0)
    create(:order_item, bakery: bakery, order: wholesale_order, product: cookie, daily_item_count: 0, thursday: 100)

    report = described_class.new(bakery, bake_date)

    expect(report.wholesale_rows).to eq([["Cookie", 125, nil, nil]])
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
      expect(workbook_xml).to include("Pull Prep")
      expect(workbook_xml).to include("Vienn Pick")

      vienn_pick_xml = zip.read("xl/worksheets/sheet4.xml")
      expect(vienn_pick_xml).to include("ref='A3:A4'")
      expect(vienn_pick_xml).to include("ref='B3:C3'", "ref='D3:E3'", "ref='F3:G3'", "ref='H3:I3'", "ref='J3:K3'")
      expect(vienn_pick_xml).to include('width="14" min="2" max="2"')
    end
  end
end
