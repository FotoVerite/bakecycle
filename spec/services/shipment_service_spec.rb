require 'rails_helper'

describe ShipmentService do
  context 'creates shipments' do
    it 'creates shipments for orders and dates where the production date is today' do
      order = create(:order, start_date: Date.today, lead_time: 2)
      ShipmentService.run
      expect(Shipment.count).to eq(2)
      expect(Shipment.last.date).to eq(Date.today + order.lead_time.days)
    end

    it "doesn't create multiple shipments for the same client, route, and date" do
      create(:order, start_date: Date.today, lead_time: 1)
      ShipmentService.run
      expect(Shipment.count).to eq(1)
      ShipmentService.run
      expect(Shipment.count).to eq(1)
    end
  end

  describe '.ship_order' do
    it 'creates a shipment for an order' do
      order = create(:order)
      date = Date.today
      shipment = ShipmentService.ship_order(order, date)

      expect(shipment.auto_generated).to eq(true)
      expect(shipment.bakery).to eq(order.bakery)
      expect(shipment.client_id).to eq(order.client.id)
      expect(shipment.route_id).to eq(order.route.id)
      expect(shipment.date).to eq(date)
    end

    it 'copies order items into shipment items' do
      order = create(:order, order_item_count: 1)
      order_item = order.order_items.first
      date = Date.today
      shipment_item = ShipmentService.ship_order(order, date).shipment_items.first

      expect(shipment_item.product_id).to eq(order_item.product.id)
      expect(shipment_item.product_name).to eq(order_item.product.name)
      expect(shipment_item.product_sku).to eq(order_item.product.sku)
    end
  end
end
