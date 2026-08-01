# frozen_string_literal: true

require "rails_helper"

describe BakeListData do
  let(:bakery) { create(:bakery) }
  let(:bake_date) { Date.new(2026, 6, 3) } # a Wednesday

  it "puts 0 bake lead day items on the retail bake" do
    client = create(:client, bakery: bakery, name: "Smith")
    croissant = create(:product, bakery: bakery, name: "Croissant", bake_lead_days: 0)
    shipment = create(:shipment, bakery: bakery, client: client, date: bake_date)
    create(:shipment_item, shipment: shipment, product: croissant, product_quantity: 40)

    data = described_class.new(bakery, bake_date)

    expect(data.retail_items).to contain_exactly(
      hash_including(product: croissant, quantity: 40, trays: nil, lead_days: 0, client_quantities: { client => 40 })
    )
    expect(data.wholesale_items).to be_empty
  end

  it "puts 1 bake lead day items on the wholesale bake" do
    client = create(:client, bakery: bakery, name: "Wholesale Account")
    baguette = create(:product, bakery: bakery, name: "Baguette", bake_lead_days: 1)
    shipment = create(:shipment, bakery: bakery, client: client, date: bake_date + 1.day)
    create(:shipment_item, shipment: shipment, product: baguette, product_quantity: 25)

    data = described_class.new(bakery, bake_date)

    expect(data.wholesale_items).to contain_exactly(
      hash_including(product: baguette, quantity: 25, trays: nil, lead_days: 1, client_quantities: { client => 25 })
    )
    expect(data.retail_items).to be_empty
  end

  it "uses per-client bake lead day overrides to place the same product on different bakes" do
    baguette = create(:product, bakery: bakery, name: "Baguette", bake_lead_days: 1)
    smith = create(:client, bakery: bakery, name: "Smith")
    restaurant = create(:client, bakery: bakery, name: "Restaurant")
    create(:bake_lead_day_variant, product: baguette, client: smith, bake_lead_days: 0)

    retail_shipment = create(:shipment, bakery: bakery, client: smith, date: bake_date)
    create(:shipment_item, shipment: retail_shipment, product: baguette, product_quantity: 10)

    wholesale_shipment = create(:shipment, bakery: bakery, client: restaurant, date: bake_date + 1.day)
    create(:shipment_item, shipment: wholesale_shipment, product: baguette, product_quantity: 30)

    data = described_class.new(bakery, bake_date)

    expect(data.retail_items).to contain_exactly(
      hash_including(product: baguette, quantity: 10, lead_days: 0, client_quantities: { smith => 10 })
    )
    expect(data.wholesale_items).to contain_exactly(
      hash_including(product: baguette, quantity: 30, lead_days: 1, client_quantities: { restaurant => 30 })
    )
  end

  it "aggregates multiple clients for the same retail bake product" do
    smith = create(:client, bakery: bakery, name: "Smith")
    franklin = create(:client, bakery: bakery, name: "Franklin")
    croissant = create(:product, bakery: bakery, name: "Croissant", bake_lead_days: 0)

    smith_shipment = create(:shipment, bakery: bakery, client: smith, date: bake_date)
    create(:shipment_item, shipment: smith_shipment, product: croissant, product_quantity: 12)
    franklin_shipment = create(:shipment, bakery: bakery, client: franklin, date: bake_date)
    create(:shipment_item, shipment: franklin_shipment, product: croissant, product_quantity: 8)

    row = described_class.new(bakery, bake_date).retail_items.first

    expect(row).to include(product: croissant, quantity: 20)
    expect(row[:client_quantities]).to eq(smith => 12, franklin => 8)
  end

  it "omits zero-quantity bake rows" do
    client = create(:client, bakery: bakery)
    croissant = create(:product, bakery: bakery, name: "Croissant", bake_lead_days: 0)
    shipment = create(:shipment, bakery: bakery, client: client, date: bake_date)
    create(:shipment_item, shipment: shipment, product: croissant, product_quantity: 0)

    data = described_class.new(bakery, bake_date)

    expect(data.retail_items).to be_empty
    expect(data.wholesale_items).to be_empty
  end

  it "excludes removed, inactive, and pull-list products from retail and wholesale bakes" do
    client = create(:client, bakery: bakery)
    removed = create(:product, bakery: bakery, name: "Removed", bake_lead_days: 0, removed: true)
    inactive = create(:product, bakery: bakery, name: "Inactive", bake_lead_days: 0, inactive: true)
    pull_list = create(:product, bakery: bakery, name: "Laminated Dough", bake_lead_days: 0, on_pull_list: true)
    shipment = create(:shipment, bakery: bakery, client: client, date: bake_date)
    [removed, inactive, pull_list].each do |product|
      create(:shipment_item, shipment: shipment, product: product, product_quantity: 10)
    end

    data = described_class.new(bakery, bake_date)

    expect(data.retail_items).to be_empty
    expect(data.wholesale_items).to be_empty
  end

  it "builds the pull prep list from marked products using each product's bake lead time" do
    smith = create(:client, bakery: bakery, name: "Smith")
    blue_bottle = create(:client, bakery: bakery, name: "Blue Bottle Coffee Nomad")
    quiche = create(:product, bakery: bakery, name: "Quiche Lorraine", product_type: "quiche", on_pull_list: true,
                              bake_lead_days: 1)
    unmarked = create(:product, bakery: bakery, name: "Unmarked Tart", product_type: "tart_and_desert")
    create(:bake_lead_day_variant, product: quiche, client: smith, bake_lead_days: 0)

    retail_shipment = create(:shipment, bakery: bakery, client: smith, date: bake_date)
    create(:shipment_item, shipment: retail_shipment, product: quiche, product_quantity: 12)
    create(:shipment_item, shipment: retail_shipment, product: unmarked, product_quantity: 99)
    wholesale_shipment = create(:shipment, bakery: bakery, client: blue_bottle, date: bake_date + 1.day)
    create(:shipment_item, shipment: wholesale_shipment, product: quiche, product_quantity: 82)

    data = described_class.new(bakery, bake_date)

    expect(data.retail_sections).to be_empty
    expect(data.wholesale_sections).to be_empty
    expect(data.pull_prep_sections).to contain_exactly(
      hash_including(
        name: "Quiche",
        product_type: "quiche",
        rows: contain_exactly(
          hash_including(
            product: quiche,
            quantity: 94,
            client_quantities: { smith => 12, blue_bottle => 82 }
          )
        )
      )
    )
  end

  it "combines retail and wholesale quantities for viennoiserie pick rows" do
    smith = create(:client, bakery: bakery)
    restaurant = create(:client, bakery: bakery)
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                                 bake_lead_days: 1, pieces_per_tray: 20, over_bake: 0)
    create(:bake_lead_day_variant, product: croissant, client: smith, bake_lead_days: 0)

    retail_shipment = create(:shipment, bakery: bakery, client: smith, date: bake_date)
    create(:shipment_item, shipment: retail_shipment, product: croissant, product_quantity: 8)
    wholesale_shipment = create(:shipment, bakery: bakery, client: restaurant, date: bake_date + 1.day)
    create(:shipment_item, shipment: wholesale_shipment, product: croissant, product_quantity: 22)

    pick = described_class.new(bakery, bake_date).viennoiserie_pick_items
    expect(pick).to include(
      { name: "Croissant", pieces_per_tray: 20, quantity: 30, retail_quantity: 8, wholesale_quantity: 22 }
    )
  end

  it "bakes retail to order and loads the whole day's overbake onto the wholesale bake" do
    smith = create(:client, bakery: bakery)
    restaurant = create(:client, bakery: bakery)
    # 25% overbake; retail via a Smith lead-0 override, wholesale via the restaurant --
    # same fixture shape as BakeListXlsx's equivalent Wholesale Bread sheet spec.
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                                 bake_lead_days: 1, over_bake: 25)
    create(:bake_lead_day_variant, product: croissant, client: smith, bake_lead_days: 0)

    retail_shipment = create(:shipment, bakery: bakery, client: smith, date: bake_date)
    create(:shipment_item, shipment: retail_shipment, product: croissant, product_quantity: 40)
    wholesale_shipment = create(:shipment, bakery: bakery, client: restaurant, date: bake_date + 1.day)
    create(:shipment_item, shipment: wholesale_shipment, product: croissant, product_quantity: 100)

    pick = described_class.new(bakery, bake_date).viennoiserie_pick_items

    # Retail is baked to order (40, no overbake). Overbake is a whole-day
    # figure sized on the retail + wholesale grand total -- ceil(140 * 25 / 100)
    # = 35 -- and all of it lands on the wholesale bake: 100 + 35 = 135.
    expect(pick).to include(
      hash_including(name: "Croissant", retail_quantity: 40, wholesale_quantity: 135, quantity: 175)
    )
  end

  it "adds the stored RunItem overbake to the wholesale bake once kickoff has run, instead of recomputing" do
    restaurant = create(:client, bakery: bakery)
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                                 bake_lead_days: 1, over_bake: 20)
    shipment = create(:shipment, bakery: bakery, client: restaurant, date: bake_date + 1.day)
    item = create(:shipment_item, shipment: shipment, product: croissant, product_quantity: 100)

    production_run = create(:production_run, bakery: bakery, date: bake_date)
    item.update!(production_run: production_run)
    # Deliberately not ceil(100 * 20 / 100) = 20 -- proves the stored value is
    # read (matching Production Run / Daily Totals), not recomputed.
    create(:run_item, bakery: bakery, product: croissant, production_run: production_run,
                      order_quantity: 100, overbake_quantity: 8)

    pick = described_class.new(bakery, bake_date).viennoiserie_pick_items

    expect(pick).to include(hash_including(name: "Croissant", retail_quantity: 0, wholesale_quantity: 108))
  end

  # Reproduces the reported Almond Croissant bug (7/23 Bake List): the wholesale
  # delivery's production run bakes on (delivery_date - total_lead_days), which
  # can include shipment items from other delivery dates baking the same day,
  # so RunItem#order_quantity is larger than this bake list's own wholesale
  # row. The client wants the full authoritative run overbake on the wholesale
  # bake regardless (matching Production Run), so the run overbake is added
  # whole -- and retail carries none of it.
  it "loads the full production-run overbake onto the wholesale bake even when the run covers more than this row" do
    restaurant = create(:client, bakery: bakery)
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                                 bake_lead_days: 1, over_bake: 20)
    shipment = create(:shipment, bakery: bakery, client: restaurant, date: bake_date + 1.day)
    item = create(:shipment_item, shipment: shipment, product: croissant, product_quantity: 100)

    production_run = create(:production_run, bakery: bakery, date: bake_date)
    item.update!(production_run: production_run)
    # A different delivery date's shipment items also bake on this same run for
    # the same product, so the run's order_quantity (120) exceeds this bake
    # list's own wholesale row (100).
    other_date_shipment = create(:shipment, bakery: bakery, client: create(:client, bakery: bakery),
                                            date: bake_date + 3.days)
    create(:shipment_item, shipment: other_date_shipment, product: croissant, product_quantity: 20,
                           production_run: production_run)
    create(:run_item, bakery: bakery, product: croissant, production_run: production_run,
                      order_quantity: 120, overbake_quantity: 12)

    pick = described_class.new(bakery, bake_date).viennoiserie_pick_items

    # Wholesale bake = its own order (100) + the full authoritative run
    # overbake (12) = 112. Retail carries none of it.
    expect(pick).to include(hash_including(name: "Croissant", retail_quantity: 0, wholesale_quantity: 112))
  end

  # Reproduces the reported bug: a bread-sheet product with retail orders but
  # no wholesale orders that day was missing from the Wholesale Bread sheet
  # entirely, even though its overbake (carried wholly by wholesale) still
  # showed on Vienn Pick, which walks every active on_vienn_pick product
  # rather than only ones with an existing wholesale row.
  it "still carries the day's overbake onto the Wholesale Bread sheet for a retail-only product" do
    smith = create(:client, bakery: bakery, name: "Smith")
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                                 bake_lead_days: 0, over_bake: 25)

    shipment = create(:shipment, bakery: bakery, client: smith, date: bake_date)
    create(:shipment_item, shipment: shipment, product: croissant, product_quantity: 40)

    data = described_class.new(bakery, bake_date)

    expect(data.wholesale_items).to be_empty
    # ceil(40 * 25 / 100) = 10, all of it landing on the wholesale bake.
    expect(data.wholesale_sections).to contain_exactly(
      hash_including(
        rows: contain_exactly(hash_including(product: croissant, quantity: 0))
      )
    )
    xlsx = BakeListXlsx.new(bakery, bake_date)
    expect(xlsx.wholesale_rows).to contain_exactly(["Croissant", 10, nil, nil])
  end

  it "uses the authoritative RunItem overbake for a retail-only product's Wholesale Bread row once kickoff has run" do
    smith = create(:client, bakery: bakery, name: "Smith")
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                                 bake_lead_days: 0, over_bake: 25)

    shipment = create(:shipment, bakery: bakery, client: smith, date: bake_date)
    create(:shipment_item, shipment: shipment, product: croissant, product_quantity: 40)

    production_run = create(:production_run, bakery: bakery, date: bake_date)
    # Deliberately not ceil(40 * 25 / 100) = 10 -- proves the stored value is
    # read (matching Production Run / Daily Totals), not recomputed.
    create(:run_item, bakery: bakery, product: croissant, production_run: production_run,
                      order_quantity: 40, overbake_quantity: 7)

    xlsx = BakeListXlsx.new(bakery, bake_date)

    expect(xlsx.wholesale_rows).to contain_exactly(["Croissant", 7, nil, nil])
  end

  it "does not add a Wholesale Bread row for a retail-only product with no overbake" do
    smith = create(:client, bakery: bakery, name: "Smith")
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                                 bake_lead_days: 0, over_bake: 0)

    shipment = create(:shipment, bakery: bakery, client: smith, date: bake_date)
    create(:shipment_item, shipment: shipment, product: croissant, product_quantity: 40)

    data = described_class.new(bakery, bake_date)

    expect(data.wholesale_sections).to be_empty
  end

  it "leaves items with nothing ordered off the pick, keeping only Pate Fermentee" do
    create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie", pieces_per_tray: 20)
    # non-viennoiserie and inactive/removed products stay off the pick
    create(:product, bakery: bakery, name: "Baguette", product_type: "bread")
    create(:product, bakery: bakery, name: "Old Danish", product_type: "vienoisserie", inactive: true)

    pick = described_class.new(bakery, bake_date).viennoiserie_pick_items
    names = pick.map { |row| row[:name] }

    expect(names).to eq(["Pate Fermentee"])
  end

  it "lists an active viennoiserie once it has an order that day" do
    client = create(:client, bakery: bakery)
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                                 pieces_per_tray: 20, bake_lead_days: 0, over_bake: 0)
    shipment = create(:shipment, bakery: bakery, client: client, date: bake_date)
    create(:shipment_item, shipment: shipment, product: croissant, product_quantity: 5)

    pick = described_class.new(bakery, bake_date).viennoiserie_pick_items
    names = pick.map { |row| row[:name] }

    expect(names).to include("Croissant")
  end

  it "collapses the Roule family into a single pick row summing every flavor" do
    client = create(:client, bakery: bakery)
    cinnamon = create(:product, bakery: bakery, name: "Roule, Cinnamon", product_type: "vienoisserie",
                                bake_lead_days: 0, pieces_per_tray: 120, over_bake: 0)
    everything = create(:product, bakery: bakery, name: "Roule, Everything", product_type: "vienoisserie",
                                  bake_lead_days: 0, pieces_per_tray: 120, over_bake: 0)
    shipment = create(:shipment, bakery: bakery, client: client, date: bake_date)
    create(:shipment_item, shipment: shipment, product: cinnamon, product_quantity: 10)
    create(:shipment_item, shipment: shipment, product: everything, product_quantity: 5)

    pick = described_class.new(bakery, bake_date).viennoiserie_pick_items
    names = pick.map { |row| row[:name] }

    expect(names).to include("Roule")
    expect(names).not_to include("Roule, Cinnamon", "Roule, Everything")
    roule_row = pick.find { |row| row[:name] == "Roule" }
    expect(roule_row).to include(pieces_per_tray: 120, quantity: 15, retail_quantity: 15, wholesale_quantity: 0)
  end

  it "sums each Roule flavor's own overbake before collapsing into the family row" do
    client = create(:client, bakery: bakery)
    # Different over_bake percentages per flavor -- the collapse must apply
    # each one individually, not one blended rate against the family total.
    cinnamon = create(:product, bakery: bakery, name: "Roule, Cinnamon", product_type: "vienoisserie",
                                bake_lead_days: 1, pieces_per_tray: 120, over_bake: 10)
    everything = create(:product, bakery: bakery, name: "Roule, Everything", product_type: "vienoisserie",
                                  bake_lead_days: 1, pieces_per_tray: 120, over_bake: 50)
    shipment = create(:shipment, bakery: bakery, client: client, date: bake_date + 1.day)
    create(:shipment_item, shipment: shipment, product: cinnamon, product_quantity: 10)
    create(:shipment_item, shipment: shipment, product: everything, product_quantity: 10)

    roule_row = described_class.new(bakery, bake_date).viennoiserie_pick_items.find { |row| row[:name] == "Roule" }

    # cinnamon: 10 + ceil(10 * 10/100) = 11; everything: 10 + ceil(10 * 50/100) = 15; sum = 26
    expect(roule_row).to include(retail_quantity: 0, wholesale_quantity: 26, quantity: 26)
  end

  it "keeps Croissant variants as separate pick rows, each with its own tray size" do
    client = create(:client, bakery: bakery)
    plain = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                             bake_lead_days: 0, pieces_per_tray: 60, over_bake: 0)
    almond = create(:product, bakery: bakery, name: "Almond Croissant", product_type: "vienoisserie",
                              bake_lead_days: 0, pieces_per_tray: 20, over_bake: 0)
    ham_brie = create(:product, bakery: bakery, name: "Ham & Brie Croissant", product_type: "vienoisserie",
                                bake_lead_days: 0, pieces_per_tray: 60, over_bake: 0)
    shipment = create(:shipment, bakery: bakery, client: client, date: bake_date)
    create(:shipment_item, shipment: shipment, product: plain, product_quantity: 10)
    create(:shipment_item, shipment: shipment, product: almond, product_quantity: 5)
    create(:shipment_item, shipment: shipment, product: ham_brie, product_quantity: 3)

    pick = described_class.new(bakery, bake_date).viennoiserie_pick_items
    names = pick.map { |row| row[:name] }

    expect(names).to include("Croissant", "Almond Croissant", "Ham & Brie Croissant")
    expect(pick.find { |row| row[:name] == "Croissant" })
      .to include(pieces_per_tray: 60, quantity: 10, retail_quantity: 10)
    expect(pick.find { |row| row[:name] == "Almond Croissant" })
      .to include(pieces_per_tray: 20, quantity: 5, retail_quantity: 5)
    expect(pick.find { |row| row[:name] == "Ham & Brie Croissant" })
      .to include(pieces_per_tray: 60, quantity: 3, retail_quantity: 3)
  end

  it "folds the plural-named base pastry 'Croissants for Almond Croissants' into the Croissant row too" do
    client = create(:client, bakery: bakery)
    plain = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                             bake_lead_days: 0, pieces_per_tray: 20, over_bake: 0)
    base_pastry = create(:product, bakery: bakery, name: "Croissants for Almond Croissants",
                                   product_type: "vienoisserie", bake_lead_days: 0, pieces_per_tray: 20, over_bake: 0)
    shipment = create(:shipment, bakery: bakery, client: client, date: bake_date)
    create(:shipment_item, shipment: shipment, product: plain, product_quantity: 10)
    create(:shipment_item, shipment: shipment, product: base_pastry, product_quantity: 5)

    pick = described_class.new(bakery, bake_date).viennoiserie_pick_items
    names = pick.map { |row| row[:name] }

    expect(names).to include("Croissant")
    expect(names).not_to include("Croissants for Almond Croissants")
    croissant_row = pick.find { |row| row[:name] == "Croissant" }
    expect(croissant_row).to include(quantity: 15, retail_quantity: 15, wholesale_quantity: 0)
  end

  it "does not let the Croissant family swallow unrelated products, and keeps Roule separate from Croissant" do
    client = create(:client, bakery: bakery)
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                                 bake_lead_days: 0, over_bake: 0)
    roule = create(:product, bakery: bakery, name: "Roule, Cinnamon", product_type: "vienoisserie",
                             bake_lead_days: 0, over_bake: 0)
    danish = create(:product, bakery: bakery, name: "Danish, Apple", product_type: "vienoisserie",
                              bake_lead_days: 0, over_bake: 0)
    shipment = create(:shipment, bakery: bakery, client: client, date: bake_date)
    create(:shipment_item, shipment: shipment, product: croissant, product_quantity: 1)
    create(:shipment_item, shipment: shipment, product: roule, product_quantity: 1)
    create(:shipment_item, shipment: shipment, product: danish, product_quantity: 1)

    names = described_class.new(bakery, bake_date).viennoiserie_pick_items.map { |row| row[:name] }

    expect(names).to include("Croissant", "Roule", "Danish, Apple")
  end

  it "appends a fixed 8-tray Pate Fermentee prep row" do
    pick = described_class.new(bakery, bake_date).viennoiserie_pick_items

    expect(pick.last).to eq(
      { name: "Pate Fermentee", pieces_per_tray: nil, retail_quantity: 0,
        wholesale_quantity: 0, quantity: 0, fixed_trays: 8 }
    )
  end
end
