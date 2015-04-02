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

  describe '.ship_order' do
    it 'creates a shipment for an order' do
      order = create(:order, bakery: bakery)
      shipment = shipment_service.ship_order(order, today)

      expect(shipment.auto_generated).to eq(true)
      expect(shipment.bakery).to eq(order.bakery)
      expect(shipment.client_id).to eq(order.client.id)
      expect(shipment.route_id).to eq(order.route.id)
      expect(shipment.date).to eq(today)
    end

    it 'copies order items into shipment items' do
      order = create(:order, order_item_count: 1, bakery: bakery)
      order_item = order.order_items.first
      shipment_service_order = shipment_service.ship_order(order, today)
      shipment_item = shipment_service_order.shipment_items.first

      expect(shipment_item.product_id).to eq(order_item.product.id)
      expect(shipment_item.product_name).to eq(order_item.product.name)
      expect(shipment_item.product_sku).to eq(order_item.product.sku)
      expect(shipment_item.production_start).to be < today
    end

    it "doesn't create shipment items with a 0 quantity" do
      order = create(:order, order_item_count: 2, bakery: bakery)
      order.order_items.first.update!(
        monday: 0,
        tuesday: 0,
        wednesday: 0,
        thursday: 0,
        friday: 0,
        saturday: 0,
        sunday: 0
      )
      shipment = shipment_service.ship_order(order, today)
      expect(shipment.shipment_items.count).to eq(1)
    end

    it "doesn't create shipments with 0 quantity" do
      order = create(:order, order_item_count: 1, bakery: bakery)
      order.order_items.first.update!(
        monday: 0,
        tuesday: 0,
        wednesday: 0,
        thursday: 0,
        friday: 0,
        saturday: 0,
        sunday: 0
      )
      shipment = shipment_service.ship_order(order, today)
      expect(shipment).to be_nil
    end
  end

  describe '.delivery_fee' do
    it 'sets delivery fee to 0 if client has no delivery fees' do
      client = create(:client, delivery_fee_option: 0, bakery: bakery)
      order = create(:order, start_date: today, client: client, bakery: bakery)
      shipment = shipment_service.ship_order(order, today)
      expect(shipment.delivery_fee).to eq(0)
    end

    it 'sets delivery fee if client has delivery fees' do
      client = create(:client, delivery_fee_option: 1, delivery_minimum: 100, delivery_fee: 25, bakery: bakery)
      product = create(:product, base_price: 10, bakery: bakery)
      order = create(:order, start_date: today, client: client, bakery: bakery)
      order.order_items.first.update_attributes(
        product: product,
        monday: 1,
        tuesday: 1,
        wednesday: 1,
        thursday: 1,
        friday: 1,
        saturday: 1,
        sunday: 1)
      shipment = shipment_service.ship_order(order, today)

      expect(order.client_daily_delivery_fee?).to eq(true)
      expect(order.daily_subtotal(today)).to be < order.client_delivery_minimum
      expect(shipment.delivery_fee).to eq(25)
    end
  end
end
