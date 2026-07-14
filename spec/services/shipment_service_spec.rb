# frozen_string_literal: true

require "rails_helper"

describe ShipmentService do
  let(:today) { Time.zone.today }
  let(:tomorrow) { today + 1.day }
  let(:bakery) { create(:bakery) }
  let(:shipment_service) { ShipmentService.new(bakery, today) }

  it "creates shipments only for order items that start production today" do
    ready_today = create(
      :order,
      bakery: bakery,
      start_date: today - 2.days,
      order_item_count: 1,
      force_total_lead_days: 2,
      daily_item_count: 1
    )
    shipment_service.run

    expect(Shipment.where(order: ready_today, date: today + 2.days)).to exist
  end

  it "does not create shipments for the ten-day horizon" do
    create(
      :order,
      bakery: bakery,
      start_date: today,
      order_item_count: 1,
      force_total_lead_days: 2,
      daily_item_count: 1
    )

    shipment_service.run

    expect(Shipment.pluck(:date)).to contain_exactly(today + 2.days)
  end
end
