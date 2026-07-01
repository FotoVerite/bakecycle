# frozen_string_literal: true

require "rails_helper"

describe ShipmentHorizonService do
  let(:today) { Date.new(2026, 6, 1) }
  let(:bakery) { create(:bakery) }

  it "creates shipments for active orders through ten days out" do
    create(:order, bakery: bakery, start_date: today, order_item_count: 1, daily_item_count: 3)
    create(:order, bakery: bakery, start_date: today + 10.days, order_item_count: 1, daily_item_count: 3)
    create(:order, bakery: bakery, start_date: today + 11.days, order_item_count: 1, daily_item_count: 3)

    described_class.new(bakery, today).run

    expect(Shipment.pluck(:date)).to include(today, today + 10.days)
    expect(Shipment.pluck(:date)).to_not include(today + 11.days)
  end

  it "does not create duplicate shipments when run more than once" do
    create(:order, bakery: bakery, start_date: today, order_item_count: 1, daily_item_count: 3)

    described_class.new(bakery, today).run
    described_class.new(bakery, today).run

    expect(Shipment.count).to eq(11)
  end

  it "uses temporary orders to override standing orders for a delivery date" do
    product = create(:product, bakery: bakery)
    standing = create(:order, bakery: bakery, start_date: today, order_item_count: 0)
    create(:order_item, bakery: bakery, order: standing, product: product, daily_item_count: 5)
    temporary = create(
      :temporary_order,
      bakery: bakery,
      client: standing.client,
      route: standing.route,
      start_date: today + 2.days,
      order_item_count: 0
    )
    create(:order_item, bakery: bakery, order: temporary, product: product, daily_item_count: 0)

    described_class.new(bakery, today).run

    expect(Shipment.where(date: today + 2.days)).to be_empty
    expect(Shipment.where(date: today + 1.day)).to exist
    expect(Shipment.where(date: today + 3.days)).to exist
  end

  it "skips orders with no positive items" do
    order = create(:order, bakery: bakery, start_date: today, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, daily_item_count: 0)

    described_class.new(bakery, today).run

    expect(Shipment.count).to eq(0)
  end
end
