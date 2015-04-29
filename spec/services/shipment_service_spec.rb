require 'rails_helper'

describe ShipmentService do
  let(:today) { Time.zone.today }
  let(:bakery) { create(:bakery) }
  let(:shipment_service) { ShipmentService.new(bakery, today) }

  context 'creates shipments' do
    it 'creates shipments for orders and dates where the production date is today' do
      order = create(:order, bakery: bakery, start_date: today, total_lead_days: 2)
      shipment_service.run
      expect(Shipment.count).to eq(2)
      expect(Shipment.last.date).to eq(today + order.total_lead_days.days)
    end

    it "doesn't create multiple shipments for the same client, route, and date" do
      create(:order, bakery: bakery, start_date: today, total_lead_days: 1)
      shipment_service.run
      expect(Shipment.count).to eq(1)
      shipment_service.run
      expect(Shipment.count).to eq(1)
    end

    it 'creates shipments for all clients of bakery' do
      create(:order, bakery: bakery, start_date: today, total_lead_days: 1)
      create(:order, bakery: bakery, start_date: today + 1.day, total_lead_days: 1)
      create(:order, bakery: bakery, start_date: today + 2.days, total_lead_days: 1)
      shipment_service.run
      expect(Shipment.count).to eq(2)
    end
  end
end
