require 'rails_helper'

describe ShipmentService do
  let(:today) { Time.zone.today }
  let(:tomorrow) { today + 1.day }
  let(:bakery) { create(:bakery) }
  let(:shipment_service) { ShipmentService.new(bakery, today) }

  context 'creates shipments' do
    it 'creates shipments for orders and dates where the production date is today' do
      create(:order, bakery: bakery, start_date: today, product_total_lead_days: 1)
      create(:order, bakery: bakery, start_date: tomorrow, product_total_lead_days: 1)
      create(:order, bakery: bakery, start_date: today + 2.days, product_total_lead_days: 1)
      shipment_service.run
      expect(Shipment.count).to eq(2)
    end

    it "doesn't create multiple shipments for the same client, route, and date" do
      create(:order, bakery: bakery, start_date: tomorrow, product_total_lead_days: 1)
      shipment_service.run
      expect(Shipment.count).to eq(1)
      shipment_service.run
      expect(Shipment.count).to eq(1)
    end

    it 'creates shipments for all clients of bakery' do
      create(:order, bakery: bakery, start_date: today, product_total_lead_days: 1)
      create(:order, bakery: bakery, start_date: today + 1.day, product_total_lead_days: 1)
      create(:order, bakery: bakery, start_date: today + 2.days, product_total_lead_days: 1)
      shipment_service.run
      expect(Shipment.count).to eq(2)
    end

    it 'does not create shipments for orders that are not active' do
      order = create(
        :order,
        bakery: bakery,
        start_date: Date.parse('2015-06-29'),
        end_date: Date.parse('2015-07-05'),
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
        start_date: Date.parse('2015-07-05'),
        order_items: [
          build(:order_item, bakery: bakery, force_total_lead_days: 1)
        ]
      )
      ShipmentService.new(bakery, Date.parse('2015-07-03')).run
      ShipmentService.new(bakery, Date.parse('2015-07-04')).run
      expect(Shipment.count).to eq(2)
      expect(Shipment.pluck(:order_id)).to contain_exactly(temp.id, order.id)
    end
  end
end
