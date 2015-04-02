require 'rails_helper'

describe ShipmentService do
  let(:today) { Date.today }
  let(:bakery) { create(:bakery) }
  let(:after_kickoff_time) do
    kickoff = bakery.kickoff_time + 1.hour
    Time.new(today.year, today.month, today.day, kickoff.hour, kickoff.min, kickoff.sec)
  end
  let(:shipment_service) { ShipmentService.new(bakery, after_kickoff_time) }

  context 'creates shipments' do
    it 'creates shipments for orders and dates where the production date is today' do
      order = create(:order, start_date: today, total_lead_days: 2)
      ShipmentService.run(after_kickoff_time)
      expect(Shipment.count).to eq(2)
      expect(Shipment.last.date).to eq(today + order.total_lead_days.days)
    end

    it "doesn't create multiple shipments for the same client, route, and date" do
      create(:order, start_date: today, total_lead_days: 1)
      ShipmentService.run(after_kickoff_time)
      expect(Shipment.count).to eq(1)
      ShipmentService.run(after_kickoff_time)
      expect(Shipment.count).to eq(1)
    end

    it 'assigns last_kickoff time to bakery when you run shipment service' do
      current_time = Chronic.parse('3 pm')
      create(:order, start_date: today, total_lead_days: 1, bakery: bakery)
      shipment_service.run
      expect(Shipment.count).to eq(1)
      bakery.reload
      expect(bakery.last_kickoff).to eq(current_time)
    end

    it 'updates last_kickoff time to bakery when last_kickoff is over 24 hours' do
      bakery = create(:bakery, last_kickoff: Date.today - 24.hours, kickoff_time: Chronic.parse('2 pm'))
      current_time = Chronic.parse('3 pm')
      create(:order, start_date: today, total_lead_days: 1, bakery: bakery)
      ShipmentService.run(current_time)
      expect(Shipment.count).to eq(1)
      expect(Bakery.first.last_kickoff).to eq(current_time)
    end
  end
end
