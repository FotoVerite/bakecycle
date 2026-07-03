# frozen_string_literal: true

require "rails_helper"

describe BakeListData do
  let(:bakery) { create(:bakery) }
  let(:bake_date) { Date.new(2026, 6, 3) } # a Wednesday

  it "splits a retail client's item into the same-day section" do
    retail_client = create(:client, bakery: bakery, bake_channel: "retail")
    croissant = create(:product, bakery: bakery, name: "Croissant", bake_lead_days: 0)
    order = create(:order, bakery: bakery, client: retail_client, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: croissant, daily_item_count: 0, wednesday: 40)

    data = described_class.new(bakery, bake_date)

    expect(data.retail_items).to eq([{ product: croissant, quantity: 40, trays: nil }])
    expect(data.wholesale_items).to be_empty
  end

  it "splits a wholesale client's item into the day-before section" do
    wholesale_client = create(:client, bakery: bakery, bake_channel: "wholesale")
    baguette = create(:product, bakery: bakery, name: "Baguette", bake_lead_days: 1)
    order = create(:order, bakery: bakery, client: wholesale_client, start_date: bake_date + 1.day,
      order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: baguette, daily_item_count: 0, thursday: 25)

    data = described_class.new(bakery, bake_date)

    expect(data.wholesale_items).to eq([{ product: baguette, quantity: 25, trays: nil }])
    expect(data.retail_items).to be_empty
  end

  it "resolves the same product onto both sheets depending on the order's client (the Baguette case)" do
    baguette = create(:product, bakery: bakery, name: "Baguette", bake_lead_days: 1)
    retail_client = create(:client, bakery: bakery, bake_channel: "retail")
    wholesale_client = create(:client, bakery: bakery, bake_channel: "wholesale")
    create(:bake_lead_day_variant, product: baguette, client: retail_client, bake_lead_days: 0)

    retail_order = create(:order, bakery: bakery, client: retail_client, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: retail_order, product: baguette, daily_item_count: 0, wednesday: 10)

    wholesale_order = create(:order, bakery: bakery, client: wholesale_client, start_date: bake_date + 1.day,
      order_item_count: 0)
    create(:order_item, bakery: bakery, order: wholesale_order, product: baguette, daily_item_count: 0, thursday: 30)

    data = described_class.new(bakery, bake_date)

    expect(data.retail_items).to eq([{ product: baguette, quantity: 10, trays: nil }])
    expect(data.wholesale_items).to eq([{ product: baguette, quantity: 30, trays: nil }])
  end

  it "does not assume wholesale means exactly 1 lead day (channel and lead time are independent)" do
    wholesale_client = create(:client, bakery: bakery, bake_channel: "wholesale")
    croissant = create(:product, bakery: bakery, name: "Croissant", bake_lead_days: 2)
    order = create(:order, bakery: bakery, client: wholesale_client, start_date: bake_date + 2.days,
      order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: croissant, daily_item_count: 0, friday: 18)

    data = described_class.new(bakery, bake_date)

    expect(data.wholesale_items).to eq([{ product: croissant, quantity: 18, trays: nil }])
  end

  it "excludes items from clients with no retail/wholesale bake_channel classification" do
    unclassified_client = create(:client, bakery: bakery, bake_channel: "not_applicable")
    croissant = create(:product, bakery: bakery, name: "Croissant", bake_lead_days: 0)
    order = create(:order, bakery: bakery, client: unclassified_client, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: croissant, daily_item_count: 0, wednesday: 40)

    data = described_class.new(bakery, bake_date)

    expect(data.retail_items).to be_empty
    expect(data.wholesale_items).to be_empty
  end

  it "excludes pull/prep items (bake_lead_days nil) from retail and wholesale" do
    retail_client = create(:client, bakery: bakery, bake_channel: "retail")
    frozen_dough = create(:product, bakery: bakery, name: "Frozen Dough", bake_lead_days: nil)
    order = create(:order, bakery: bakery, client: retail_client, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: frozen_dough, daily_item_count: 0, wednesday: 15)

    data = described_class.new(bakery, bake_date)

    expect(data.retail_items).to be_empty
    expect(data.wholesale_items).to be_empty
  end

  it "lists pull_list_items from Product#on_pull_list, computing same-day quantity" do
    laminated = create(:product, bakery: bakery, name: "Laminated Dough", on_pull_list: true, pieces_per_tray: 5)
    order = create(:order, bakery: bakery, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: laminated, daily_item_count: 0, wednesday: 12)

    data = described_class.new(bakery, bake_date)

    expect(data.pull_list_items).to eq([{ product: laminated, quantity: 12, trays: "2 trays + 2 pcs" }])
  end

  it "cross-references retail and wholesale for viennoiserie_pick_items, filtered to vienoisserie" do
    retail_client = create(:client, bakery: bakery, bake_channel: "retail")
    wholesale_client = create(:client, bakery: bakery, bake_channel: "wholesale")
    croissant = create(:product, bakery: bakery, name: "Croissant", product_type: "vienoisserie", bake_lead_days: 0)
    baguette = create(:product, bakery: bakery, name: "Baguette", product_type: "bread", bake_lead_days: 1)
    retail_order = create(:order, bakery: bakery, client: retail_client, start_date: bake_date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: retail_order, product: croissant, daily_item_count: 0, wednesday: 8)
    wholesale_order = create(:order, bakery: bakery, client: wholesale_client, start_date: bake_date + 1.day,
      order_item_count: 0)
    create(:order_item, bakery: bakery, order: wholesale_order, product: baguette, daily_item_count: 0, thursday: 20)

    data = described_class.new(bakery, bake_date)

    expect(data.viennoiserie_pick_items).to eq([{ product: croissant, quantity: 8, trays: nil }])
  end
end
