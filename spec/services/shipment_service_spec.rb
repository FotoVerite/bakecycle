# frozen_string_literal: true

require "rails_helper"

describe ShipmentService do
  let(:today) { Time.zone.today }
  let(:tomorrow) { today + 1.day }
  let(:bakery) { create(:bakery) }
  let(:shipment_service) { ShipmentService.new(bakery, today) }

  it "delegates shipment generation to the horizon service" do
    horizon_service = instance_double(ShipmentHorizonService, run: true)

    expect(ShipmentHorizonService).to receive(:new).with(bakery, today).and_return(horizon_service)

    shipment_service.run
  end

  context "creates shipments" do
    it "creates shipments for active orders through ten days out" do
      create(:order, bakery: bakery, start_date: today, order_item_count: 1, daily_item_count: 1)
      create(:order, bakery: bakery, start_date: today + 10.days, order_item_count: 1, daily_item_count: 1)
      create(:order, bakery: bakery, start_date: today + 11.days, order_item_count: 1, daily_item_count: 1)
      shipment_service.run
      expect(Shipment.pluck(:date)).to include(today, today + 10.days)
      expect(Shipment.pluck(:date)).to_not include(today + 11.days)
    end

    it "doesn't create multiple shipments for the same client, route, and date" do
      create(:order, bakery: bakery, start_date: tomorrow, order_item_count: 1, daily_item_count: 1)
      shipment_service.run
      expect(Shipment.count).to eq(10)
      shipment_service.run
      expect(Shipment.count).to eq(10)
    end

    it "creates shipments for all clients of bakery" do
      create(:order, bakery: bakery, start_date: today, order_item_count: 1, daily_item_count: 1)
      create(:order, bakery: bakery, start_date: today + 1.day, order_item_count: 1, daily_item_count: 1)
      create(:order, bakery: bakery, start_date: today + 2.days, order_item_count: 1, daily_item_count: 1)
      shipment_service.run
      expect(Shipment.count).to eq(30)
    end

    it "uses the active order for each date in the horizon" do
      order = create(
        :order,
        bakery: bakery,
        start_date: Date.parse("2015-06-29"),
        end_date: Date.parse("2015-07-05"),
        order_items: [
          build(:order_item, bakery: bakery, force_total_lead_days: 1),
          build(:order_item, bakery: bakery, force_total_lead_days: 2)
        ]
      )
      temp = create(
        :temporary_order,
        bakery: bakery,
        client: order.client,
        route: order.route,
        start_date: Date.parse("2015-07-05"),
        order_items: [
          build(:order_item, bakery: bakery, force_total_lead_days: 1)
        ]
      )
      ShipmentService.new(bakery, Date.parse("2015-07-03")).run
      ShipmentService.new(bakery, Date.parse("2015-07-04")).run
      expect(Shipment.count).to eq(3)
      expect(Shipment.where(date: Date.parse("2015-07-05")).pluck(:order_id)).to contain_exactly(temp.id)
      expect(Shipment.where(date: Date.parse("2015-07-03")..Date.parse("2015-07-04")).pluck(:order_id)).to contain_exactly(order.id, order.id)
    end
  end
end
