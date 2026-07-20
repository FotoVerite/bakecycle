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

  it "sizes the Vienn Pick's overbake off each side's own quantity, not a retail+wholesale combined total" do
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

    # Retail-lead and wholesale-lead orders for the same product are baked on
    # different physical days, never the same batch -- each side gets its own
    # margin against its own quantity: retail ceil(40 * 25 / 100) = 10 -> 50,
    # wholesale ceil(100 * 25 / 100) = 25 -> 125.
    expect(pick).to include(
      hash_including(name: "Croissant", retail_quantity: 50, wholesale_quantity: 125, quantity: 175)
    )
  end

  it "lists every active viennoiserie on the pick, showing zero when there are no orders" do
    create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie", pieces_per_tray: 20)
    # non-viennoiserie and inactive/removed products stay off the pick
    create(:product, bakery: bakery, name: "Baguette", product_type: "bread")
    create(:product, bakery: bakery, name: "Old Danish", product_type: "vienoisserie", inactive: true)

    pick = described_class.new(bakery, bake_date).viennoiserie_pick_items
    names = pick.map { |row| row[:name] }

    expect(names).to include("Croissant")
    expect(names).not_to include("Baguette", "Old Danish")
    croissant_row = pick.find { |row| row[:name] == "Croissant" }
    expect(croissant_row).to include(quantity: 0, retail_quantity: 0, wholesale_quantity: 0)
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

  it "collapses the Croissant family into a single pick row summing every variant" do
    client = create(:client, bakery: bakery)
    plain = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie",
                             bake_lead_days: 0, pieces_per_tray: 20, over_bake: 0)
    almond = create(:product, bakery: bakery, name: "Almond Croissant", product_type: "vienoisserie",
                              bake_lead_days: 0, pieces_per_tray: 20, over_bake: 0)
    ham_brie = create(:product, bakery: bakery, name: "Ham & Brie Croissant", product_type: "vienoisserie",
                                bake_lead_days: 0, pieces_per_tray: 20, over_bake: 0)
    shipment = create(:shipment, bakery: bakery, client: client, date: bake_date)
    create(:shipment_item, shipment: shipment, product: plain, product_quantity: 10)
    create(:shipment_item, shipment: shipment, product: almond, product_quantity: 5)
    create(:shipment_item, shipment: shipment, product: ham_brie, product_quantity: 3)

    pick = described_class.new(bakery, bake_date).viennoiserie_pick_items
    names = pick.map { |row| row[:name] }

    expect(names).to include("Croissant")
    expect(names).not_to include("Almond Croissant", "Ham & Brie Croissant")
    croissant_row = pick.find { |row| row[:name] == "Croissant" }
    expect(croissant_row).to include(pieces_per_tray: 20, quantity: 18, retail_quantity: 18, wholesale_quantity: 0)
  end

  it "does not let the Croissant family swallow unrelated products, and keeps Roule separate from Croissant" do
    create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie")
    create(:product, bakery: bakery, name: "Roule, Cinnamon", product_type: "vienoisserie")
    create(:product, bakery: bakery, name: "Danish, Apple", product_type: "vienoisserie")

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
