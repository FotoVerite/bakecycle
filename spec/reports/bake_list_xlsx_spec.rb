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

    baguette = create(:product, bakery: bakery, name: "Baguette", product_type: "bread", bake_lead_days: 0,
                                over_bake: 0)
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                                 bake_lead_days: 1, pieces_per_tray: 20, over_bake: 0)
    cookie = create(:product, bakery: bakery, name: "Chocolate Chip Cookie", product_type: "cookie",
                              bake_lead_days: 1, over_bake: 0)
    create(:bake_lead_day_variant, product: croissant, client: smith, bake_lead_days: 0)

    smith_shipment = create(:shipment, bakery: bakery, client: smith, date: bake_date)
    create(:shipment_item, shipment: smith_shipment, product: baguette, product_quantity: 24)
    create(:shipment_item, shipment: smith_shipment, product: croissant, product_quantity: 8)

    franklin_shipment = create(:shipment, bakery: bakery, client: franklin, date: bake_date)
    create(:shipment_item, shipment: franklin_shipment, product: baguette, product_quantity: 12)

    wholesale_shipment = create(:shipment, bakery: bakery, client: restaurant, date: bake_date + 1.day)
    create(:shipment_item, shipment: wholesale_shipment, product: croissant, product_quantity: 22)
    create(:shipment_item, shipment: wholesale_shipment, product: cookie, product_quantity: 96)

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

    shipment = create(:shipment, bakery: bakery, date: bake_date + 1.day)
    [[ham_brie, 17], [almond, 5], [roule_cinnamon, 20], [roule_everything, 12]].each do |product, qty|
      create(:shipment_item, shipment: shipment, product: product, product_quantity: qty)
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
    shipment = create(:shipment, bakery: bakery, date: bake_date)
    create(:shipment_item, shipment: shipment, product: cinnamon, product_quantity: 20)
    create(:shipment_item, shipment: shipment, product: everything, product_quantity: 12)

    expect(described_class.new(bakery, bake_date).retail_rows).to eq(
      [
        ["Roule, Cinnamon", 20, 0, 0],
        ["Roule, Everything", 12, 0, 0],
        ["ROULE TOTAL", 32, nil, nil]
      ]
    )
  end

  it "adds Tray Counts for almond and chocolate almond croissants to Retail and Wholesale sheets" do
    almond = create(:product, bakery: bakery, name: "Almond Croissant", product_type: "vienoisserie",
                              bake_lead_days: 0, over_bake: 0)
    choc_almond = create(:product, bakery: bakery, name: "Chocolate Almond Croissant", product_type: "vienoisserie",
                                   bake_lead_days: 1, over_bake: 0)

    retail_shipment = create(:shipment, bakery: bakery, date: bake_date)
    create(:shipment_item, shipment: retail_shipment, product: almond, product_quantity: 24)

    wholesale_shipment = create(:shipment, bakery: bakery, date: bake_date + 1.day)
    create(:shipment_item, shipment: wholesale_shipment, product: choc_almond, product_quantity: 13)

    report = described_class.new(bakery, bake_date)

    # Almond Croissant: 24 retail, 0 wholesale that day -- Pull rounds 24/20
    # up to 2, Bake rounds 24/15 up to 2. Chocolate Almond Croissant: 0
    # retail, 13 wholesale -- Pull rounds 13/20 up to 1, Bake rounds 13/15 up
    # to 1. Both items always appear, even at 0.
    expect(report.retail_tray_count_rows).to eq(
      [
        ["Almond Croissant", 2, 2],
        ["Chocolate Almond Croissant", 0, 0]
      ]
    )
    expect(report.wholesale_tray_count_rows).to eq(
      [
        ["Almond Croissant", 0, 0],
        ["Chocolate Almond Croissant", 1, 1]
      ]
    )
  end

  it "collapses Roule flavors into one Vienn Pick row and appends a fixed Pate Fermentee tray row" do
    roule_cinnamon = create(:product, bakery: bakery, name: "Roule, Cinnamon", product_type: "vienoisserie",
                                      bake_lead_days: 1, pieces_per_tray: 120, over_bake: 0)
    roule_everything = create(:product, bakery: bakery, name: "Roule, Everything", product_type: "vienoisserie",
                                        bake_lead_days: 1, pieces_per_tray: 120, over_bake: 0)

    shipment = create(:shipment, bakery: bakery, date: bake_date + 1.day)
    [[roule_cinnamon, 130], [roule_everything, 20]].each do |product, qty|
      create(:shipment_item, shipment: shipment, product: product, product_quantity: qty)
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

  it "keeps Croissant variants as separate Vienn Pick rows, each with its own tray size" do
    plain = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                             bake_lead_days: 0, pieces_per_tray: 60, over_bake: 0)
    almond = create(:product, bakery: bakery, name: "Almond Croissant", product_type: "vienoisserie",
                              bake_lead_days: 0, pieces_per_tray: 20, over_bake: 0)

    shipment = create(:shipment, bakery: bakery, date: bake_date)
    create(:shipment_item, shipment: shipment, product: plain, product_quantity: 24)
    create(:shipment_item, shipment: shipment, product: almond, product_quantity: 6)

    report = described_class.new(bakery, bake_date)

    # Vienn Pick: two separate rows, each divided by its own tray size --
    # Croissant (24 / 60 = 0 trays + 24), Almond Croissant (6 / 20 = 0 trays + 6).
    expect(report.viennoiserie_rows).to eq(
      [
        ["Almond Croissant", 0, 6, 0, 0, nil, nil, 0, 6, nil, nil],
        ["Croissant", 0, 24, 0, 0, nil, nil, 0, 24, nil, nil],
        ["Pate Fermentee", 8, nil, nil, nil, nil, nil, nil, nil, nil, nil]
      ]
    )
    # Retail Bread: same two distinct rows, per-variant.
    expect(report.retail_rows).to eq(
      [
        ["Almond Croissant", 6, 0, 0],
        ["Croissant", 24, 0, 0]
      ]
    )
  end

  it "folds 'Croissants for Almond Croissants' into the base Croissant row's count and tray size" do
    plain = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                             bake_lead_days: 0, pieces_per_tray: 60, over_bake: 0)
    base_pastry = create(:product, bakery: bakery, name: "Croissants for Almond Croissants",
                                   product_type: "vienoisserie", bake_lead_days: 0, pieces_per_tray: 20, over_bake: 0)

    shipment = create(:shipment, bakery: bakery, date: bake_date)
    create(:shipment_item, shipment: shipment, product: plain, product_quantity: 24)
    create(:shipment_item, shipment: shipment, product: base_pastry, product_quantity: 6)

    report = described_class.new(bakery, bake_date)

    # 30 total using Croissant's own tray size (60), not the extra product's.
    expect(report.viennoiserie_rows).to eq(
      [
        ["Croissant", 0, 30, 0, 0, nil, nil, 0, 30, nil, nil],
        ["Pate Fermentee", 8, nil, nil, nil, nil, nil, nil, nil, nil, nil]
      ]
    )
  end

  it "folds Grand Central into Retail on Pull Prep, not Wholesale" do
    smith = create(:client, bakery: bakery, name: "Bien Cuit - Smith Street")
    franklin = create(:client, bakery: bakery, name: "Bien Cuit - Franklin")
    gcm = create(:client, bakery: bakery, name: "Bien Cuit - Grand Central")
    blue_bottle = create(:client, bakery: bakery, name: "Blue Bottle Coffee Nomad")
    restaurant = create(:client, bakery: bakery, name: "Some Restaurant")
    blondie = create(:product, bakery: bakery, name: "Blondie", product_type: "other", on_pull_list: true)

    quantities = { smith => 12, franklin => 16, gcm => 18, blue_bottle => 82, restaurant => 4 }
    quantities.each do |client, quantity|
      shipment = create(:shipment, bakery: bakery, client: client, date: bake_date + 1.day)
      create(:shipment_item, shipment: shipment, product: blondie, product_quantity: quantity)
    end

    report = described_class.new(bakery, bake_date)

    # Item, Total, Smith, Franklin, Grand Central, Retail (Smith + Franklin +
    # Grand Central), Blue Bottle, Wholesale (total - retail).
    expect(report.other_rows).to eq([["Blondie", 132, 12, 16, 18, 46, 82, 86]])
  end

  it "shows a fixed Smith/Franklin zero instead of dropping a store's column on a quiet day" do
    smith = create(:client, bakery: bakery, name: "Bien Cuit - Smith Street")
    baguette = create(:product, bakery: bakery, name: "Baguette", product_type: "bread", bake_lead_days: 0)
    shipment = create(:shipment, bakery: bakery, client: smith, date: bake_date)
    create(:shipment_item, shipment: shipment, product: baguette, product_quantity: 12)

    report = described_class.new(bakery, bake_date)

    # Franklin didn't order -- still present, as an explicit 0.
    expect(report.retail_rows).to eq([["Baguette", 12, 12, 0]])
  end

  it "bakes retail to order and loads the whole day's overbake onto the Wholesale Bread sheet" do
    smith = create(:client, bakery: bakery, name: "Bien Cuit - Smith Street")
    restaurant = create(:client, bakery: bakery, name: "Restaurant")
    # 25% overbake; retail via a Smith lead-0 override, wholesale via the restaurant.
    cookie = create(:product, bakery: bakery, name: "Cookie", product_type: "cookie",
                              bake_lead_days: 1, over_bake: 25)
    create(:bake_lead_day_variant, product: cookie, client: smith, bake_lead_days: 0)

    retail_shipment = create(:shipment, bakery: bakery, client: smith, date: bake_date)
    create(:shipment_item, shipment: retail_shipment, product: cookie, product_quantity: 40)
    wholesale_shipment = create(:shipment, bakery: bakery, client: restaurant, date: bake_date + 1.day)
    create(:shipment_item, shipment: wholesale_shipment, product: cookie, product_quantity: 100)

    report = described_class.new(bakery, bake_date)

    # Overbake is a whole-day figure sized on the retail + wholesale grand
    # total -- ceil(140 * 25 / 100) = 35 -- and all of it lands on the
    # Wholesale Bread sheet's Total: 100 + 35 = 135. The Retail Bread sheet is
    # order-only (40, no overbake column).
    expect(report.wholesale_rows).to eq([["Cookie", 135, nil, nil]])
    expect(report.retail_rows).to eq([["Cookie", 40, 40, 0]])
  end

  # Reproduces the reported bug: a product with a retail bake and no wholesale
  # orders that day was missing from the Wholesale Bread sheet entirely, even
  # though its overbake (carried wholly by wholesale) still showed on Vienn
  # Pick's totals and wholesale tray counts.
  it "still shows the overbake on the Wholesale Bread sheet when a product has no wholesale orders that day" do
    smith = create(:client, bakery: bakery, name: "Bien Cuit - Smith Street")
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                                 bake_lead_days: 0, over_bake: 25)

    shipment = create(:shipment, bakery: bakery, client: smith, date: bake_date)
    create(:shipment_item, shipment: shipment, product: croissant, product_quantity: 40)

    report = described_class.new(bakery, bake_date)

    # ceil(40 * 25 / 100) = 10, all of it landing on the Wholesale Bread
    # sheet even though there's no wholesale order at all.
    expect(report.wholesale_rows).to eq([["Croissant", 10, nil, nil]])
    expect(report.retail_rows).to eq([["Croissant", 40, 40, 0]])
  end

  it "sizes the overbake off wholesale alone when the product has no retail bake that day" do
    restaurant = create(:client, bakery: bakery, name: "Restaurant")
    cookie = create(:product, bakery: bakery, name: "Cookie", product_type: "cookie",
                              bake_lead_days: 1, over_bake: 25)
    wholesale_shipment = create(:shipment, bakery: bakery, client: restaurant, date: bake_date + 1.day)
    create(:shipment_item, shipment: wholesale_shipment, product: cookie, product_quantity: 100)

    report = described_class.new(bakery, bake_date)

    # No retail bake, so the grand total is just the wholesale 100:
    # ceil(100 * 25 / 100) = 25 -> 125.
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

  it "leaves a blank leading column on Retail Bread, Wholesale Bread, and Pull Prep, and renames " \
     "Wholesale's Missing/Extra headers to Count/Difference" do
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "bread", bake_lead_days: 1,
                                 over_bake: 0)
    wholesale_shipment = create(:shipment, bakery: bakery, date: bake_date + 1.day)
    create(:shipment_item, shipment: wholesale_shipment, product: croissant, product_quantity: 10)

    workbook = described_class.new(bakery, bake_date).generate

    Zip::File.open_buffer(StringIO.new(workbook)) do |zip|
      shared_strings = zip.read("xl/sharedStrings.xml")
      expect(shared_strings).to include(">COUNT<")
      expect(shared_strings).to include(">DIFFERENCE<")
      expect(shared_strings).not_to include(">MISSING<")
      expect(shared_strings).not_to include(">EXTRA<")

      # column A is header-content-free (banner merges -- title row, section
      # headers -- start at B, not A) on the three sheets that got the new
      # blank leading column, while Vienn Pick (sheet4) keeps its own
      # A3:A4/A-anchored merges untouched.
      %w[sheet1.xml sheet2.xml sheet3.xml].each do |sheet_file|
        sheet_xml = zip.read("xl/worksheets/#{sheet_file}")
        expect(sheet_xml).not_to match(/ref='A\d+:/)
      end

      # Wholesale Bread (sheet2) is guaranteed to have a section from the
      # fixture above -- assert its banner actually merges from B onward.
      wholesale_xml = zip.read("xl/worksheets/sheet2.xml")
      expect(wholesale_xml).to match(/ref='B\d+:[A-Z]+\d+'/)
    end
  end
end
