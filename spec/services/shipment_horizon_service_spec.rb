# frozen_string_literal: true

require "rails_helper"

describe ShipmentHorizonService do
  let(:today) { Date.new(2026, 6, 1) }
  let(:bakery) { create(:bakery) }

  it "projects active orders through ten days out without creating shipments" do
    current = create(:order, bakery: bakery, start_date: today, order_item_count: 1, daily_item_count: 3)
    final_day = create(:order, bakery: bakery, start_date: today + 10.days, order_item_count: 1, daily_item_count: 3)
    create(:order, bakery: bakery, start_date: today + 11.days, order_item_count: 1, daily_item_count: 3)

    projection = described_class.new(bakery, today).run

    expect(projection.map { |shipment| [shipment.order, shipment.date] }).to include(
      [current, today],
      [final_day, today + 10.days]
    )
    expect(projection.map(&:date)).not_to include(today + 11.days)
    expect(Shipment).not_to exist
    expect(ShipmentItem).not_to exist
  end

  it "does not persist anything when run more than once" do
    create(:order, bakery: bakery, start_date: today, order_item_count: 1, daily_item_count: 3)

    first_projection = described_class.new(bakery, today).run
    second_projection = described_class.new(bakery, today).run

    expect(second_projection.map { |shipment| [shipment.order.id, shipment.date] })
      .to eq(first_projection.map { |shipment| [shipment.order.id, shipment.date] })
    expect(Shipment).not_to exist
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

    projection = described_class.new(bakery, today).run

    expect(projection.map(&:date)).not_to include(today + 2.days)
    expect(projection.map(&:date)).to include(today + 1.day, today + 3.days)
    expect(Shipment).not_to exist
  end

  it "skips orders with no positive items" do
    order = create(:order, bakery: bakery, start_date: today, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, daily_item_count: 0)

    projection = described_class.new(bakery, today).run

    expect(projection).to be_empty
    expect(Shipment).not_to exist
  end
end
