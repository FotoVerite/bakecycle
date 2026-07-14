# frozen_string_literal: true

require "rails_helper"

describe BakeListData do
  let(:bakery) { create(:bakery) }
  let(:bake_date) { Date.new(2026, 6, 3) } # a Wednesday

  it "puts 0 bake lead day items on the retail bake" do
    client = create(:client, bakery: bakery, name: "Smith")
    croissant = create(:product, bakery: bakery, name: "Croissant", bake_lead_days: 0)
    order = create(:order, bakery: bakery, client: client, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: croissant, daily_item_count: 0, wednesday: 40)

    data = described_class.new(bakery, bake_date)

    expect(data.retail_items).to contain_exactly(
      hash_including(product: croissant, quantity: 40, trays: nil, lead_days: 0, client_quantities: { client => 40 })
    )
    expect(data.wholesale_items).to be_empty
  end

  it "puts 1 bake lead day items on the wholesale bake" do
    client = create(:client, bakery: bakery, name: "Wholesale Account")
    baguette = create(:product, bakery: bakery, name: "Baguette", bake_lead_days: 1)
    order = create(:order, bakery: bakery, client: client, start_date: bake_date + 1.day, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: baguette, daily_item_count: 0, thursday: 25)

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

    retail_order = create(:order, bakery: bakery, client: smith, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: retail_order, product: baguette, daily_item_count: 0, wednesday: 10)

    wholesale_order = create(
      :order,
      bakery: bakery,
      client: restaurant,
      start_date: bake_date + 1.day,
      order_item_count: 0
    )
    create(:order_item, bakery: bakery, order: wholesale_order, product: baguette, daily_item_count: 0, thursday: 30)

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

    smith_order = create(:order, bakery: bakery, client: smith, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: smith_order, product: croissant, daily_item_count: 0, wednesday: 12)
    franklin_order = create(:order, bakery: bakery, client: franklin, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: franklin_order, product: croissant, daily_item_count: 0, wednesday: 8)

    row = described_class.new(bakery, bake_date).retail_items.first

    expect(row).to include(product: croissant, quantity: 20)
    expect(row[:client_quantities]).to eq(smith => 12, franklin => 8)
  end

  it "omits zero-quantity bake rows" do
    client = create(:client, bakery: bakery)
    croissant = create(:product, bakery: bakery, name: "Croissant", bake_lead_days: 0)
    order = create(:order, bakery: bakery, client: client, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: croissant, daily_item_count: 0)

    data = described_class.new(bakery, bake_date)

    expect(data.retail_items).to be_empty
    expect(data.wholesale_items).to be_empty
  end

  it "excludes removed, inactive, and pull-list products from retail and wholesale bakes" do
    client = create(:client, bakery: bakery)
    removed = create(:product, bakery: bakery, name: "Removed", bake_lead_days: 0, removed: true)
    inactive = create(:product, bakery: bakery, name: "Inactive", bake_lead_days: 0, inactive: true)
    pull_list = create(:product, bakery: bakery, name: "Laminated Dough", bake_lead_days: 0, on_pull_list: true)
    order = create(:order, bakery: bakery, client: client, start_date: bake_date, order_item_count: 0)
    [removed, inactive, pull_list].each do |product|
      create(:order_item, bakery: bakery, order: order, product: product, daily_item_count: 0, wednesday: 10)
    end

    data = described_class.new(bakery, bake_date)

    expect(data.retail_items).to be_empty
    expect(data.wholesale_items).to be_empty
  end

  it "excludes removed order items" do
    client = create(:client, bakery: bakery)
    croissant = create(:product, bakery: bakery, name: "Croissant", bake_lead_days: 0)
    order = create(:order, bakery: bakery, client: client, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: croissant, daily_item_count: 0, wednesday: 10)
      .update_column(:removed, 1)

    expect(described_class.new(bakery, bake_date).retail_items).to be_empty
  end

  it "builds the pull prep list from marked products on the selected delivery date" do
    smith = create(:client, bakery: bakery, name: "Smith")
    blue_bottle = create(:client, bakery: bakery, name: "Blue Bottle Coffee Nomad")
    quiche = create(:product, bakery: bakery, name: "Quiche Lorraine", product_type: "quiche", on_pull_list: true)
    unmarked = create(:product, bakery: bakery, name: "Unmarked Tart", product_type: "tart_and_desert")

    retail_order = create(:order, bakery: bakery, client: smith, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: retail_order, product: quiche, daily_item_count: 0, wednesday: 12)
    create(:order_item, bakery: bakery, order: retail_order, product: unmarked, daily_item_count: 0, wednesday: 99)
    wholesale_order = create(:order, bakery: bakery, client: blue_bottle, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: wholesale_order, product: quiche, daily_item_count: 0, wednesday: 82)

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
                                 bake_lead_days: 1, pieces_per_tray: 20)
    create(:bake_lead_day_variant, product: croissant, client: smith, bake_lead_days: 0)

    retail_order = create(:order, bakery: bakery, client: smith, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: retail_order, product: croissant, daily_item_count: 0, wednesday: 8)
    wholesale_order = create(
      :order,
      bakery: bakery,
      client: restaurant,
      start_date: bake_date + 1.day,
      order_item_count: 0
    )
    create(:order_item, bakery: bakery, order: wholesale_order, product: croissant, daily_item_count: 0, thursday: 22)

    pick = described_class.new(bakery, bake_date).viennoiserie_pick_items
    expect(pick).to include(
      { name: "Croissant", pieces_per_tray: 20, quantity: 30, retail_quantity: 8, wholesale_quantity: 22 }
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
                                bake_lead_days: 0, pieces_per_tray: 120)
    everything = create(:product, bakery: bakery, name: "Roule, Everything", product_type: "vienoisserie",
                                  bake_lead_days: 0, pieces_per_tray: 120)
    order = create(:order, bakery: bakery, client: client, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: cinnamon, daily_item_count: 0, wednesday: 10)
    create(:order_item, bakery: bakery, order: order, product: everything, daily_item_count: 0, wednesday: 5)

    pick = described_class.new(bakery, bake_date).viennoiserie_pick_items
    names = pick.map { |row| row[:name] }

    expect(names).to include("Roule")
    expect(names).not_to include("Roule, Cinnamon", "Roule, Everything")
    roule_row = pick.find { |row| row[:name] == "Roule" }
    expect(roule_row).to include(pieces_per_tray: 120, quantity: 15, retail_quantity: 15, wholesale_quantity: 0)
  end

  it "appends a fixed 8-tray Pate Fermentee prep row" do
    pick = described_class.new(bakery, bake_date).viennoiserie_pick_items

    expect(pick.last).to eq(
      { name: "Pate Fermentee", pieces_per_tray: nil, retail_quantity: 0,
        wholesale_quantity: 0, quantity: 0, fixed_trays: 8 }
    )
  end
end
