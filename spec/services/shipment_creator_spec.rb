require "rails_helper"

describe ShipmentCreator do
  let(:today) { Time.zone.today }
  let(:bakery) { create(:bakery) }

  describe "#create!" do
    it "creates a shipment for an order" do
      order = create(:order, bakery: bakery)
      shipment = ShipmentCreator.new(order, today).create!

      expect(shipment).to be_persisted
      expect(shipment.auto_generated).to eq(true)
      expect(shipment.bakery).to eq(order.bakery)
      expect(shipment.client_id).to eq(order.client.id)
      expect(shipment.route_id).to eq(order.route.id)
      expect(shipment.date).to eq(today)
    end

    it "copies order items into shipment items" do
      order = create(:order, order_item_count: 1, bakery: bakery)
      order_item = order.order_items.first
      shipment_service_order = ShipmentCreator.new(order, today).create!
      shipment_item = shipment_service_order.shipment_items.first

      expect(shipment_item.product_id).to eq(order_item.product.id)
      expect(shipment_item.product_name).to eq(order_item.product.name)
      expect(shipment_item.product_sku).to eq(order_item.product.sku)
      expect(shipment_item.production_start).to be < today
    end

    it "doesn't create shipment items with a 0 quantity" do
      order = create(:order, order_item_count: 2, bakery: bakery, daily_item_count: 0)
      order.order_items.first.update!(monday: 1)
      monday = Date.new(2015, 3, 30)
      shipment = ShipmentCreator.new(order, monday).create!
      expect(shipment.shipment_items.count).to eq(1)
    end

    it "doesn't create shipments with 0 quantity" do
      order = create(:order, order_item_count: 1, bakery: bakery, daily_item_count: 0)
      shipment = ShipmentCreator.new(order, today).create!
      expect(shipment).to be_nil
    end
  end

  describe "#delivery_fee" do
    it "charges weekly fee" do
      sunday = Date.new(2015, 4, 5)
      client = create(:client, delivery_fee_option: 2, delivery_minimum: 100, delivery_fee: 25, bakery: bakery)
      order = create(:order, client: client, bakery: bakery, daily_item_count: 0)
      creator = ShipmentCreator.new(order, sunday)
      expect(creator.send(:delivery_fee)).to eq(25)
    end

    it "does not charge weekly fee" do
      saturday = Date.new(2015, 4, 4)
      sunday = Date.new(2015, 4, 5)
      client = create(:client, delivery_fee_option: 2, delivery_minimum: 1, delivery_fee: 25, bakery: bakery)
      order = create(:order, client: client, bakery: bakery, daily_item_count: 0)
      shipment = create(:shipment, bakery: bakery, client: client, date: saturday)
      expect(shipment.subtotal).to be > 1
      creator = ShipmentCreator.new(order, sunday)
      expect(creator.send(:delivery_fee)).to eq(0)
    end
  end

  describe "daily delivery fees" do
    it "does not charge fee if there is no order" do
      client = create(:client, delivery_fee_option: 1, delivery_minimum: 100, delivery_fee: 25, bakery: bakery)
      order = create(:order, order_item_count: 1, bakery: bakery, daily_item_count: 0, client: client)
      shipment = ShipmentCreator.new(order, today).create!
      expect(shipment).to be_nil
    end

    it "sets delivery fee to 0 if client has no delivery fees" do
      client = create(:client, delivery_fee_option: 0, bakery: bakery)
      order = create(:order, start_date: today, client: client, bakery: bakery)
      shipment = ShipmentCreator.new(order, today).create!
      expect(shipment.delivery_fee).to eq(0)
    end

    it "sets delivery fee if client has delivery fees" do
      client = create(:client, delivery_fee_option: 1, delivery_minimum: 100, delivery_fee: 25, bakery: bakery)
      product = create(:product, base_price: 10, bakery: bakery)
      order = create(:order, start_date: today, client: client, bakery: bakery, daily_item_count: 1, product: product)

      shipment = ShipmentCreator.new(order, today).create!
      expect(shipment.price).to eq(35)
      expect(shipment.delivery_fee).to eq(25)
    end

    it "does not set daily delivery fee if client meets minimums" do
      client = create(:client, delivery_fee_option: 1, delivery_minimum: 100, delivery_fee: 25, bakery: bakery)
      product = create(:product, base_price: 10, bakery: bakery)
      order = create(:order, start_date: today, client: client, bakery: bakery, product: product, daily_item_count: 10)
      shipment = ShipmentCreator.new(order, today).create!
      expect(shipment.delivery_fee).to eq(0)
    end
  end

  describe "weekly delivery fees" do
    let(:monday) { Date.new(2015, 3, 30) }
    let(:sunday) { Date.new(2015, 4, 5) }
    let(:client) { create(:client, delivery_fee_option: 2, delivery_minimum: 100, delivery_fee: 25, bakery: bakery) }
    let(:product) { create(:product, base_price: 10, bakery: bakery) }

    it "charged if client doesn't meet minimums" do
      order = create(:order, start_date: monday, client: client, bakery: bakery, product: product, daily_item_count: 1)

      monday_shipment = ShipmentCreator.new(order, monday).create!
      sunday_shipment = ShipmentCreator.new(order, sunday).create!

      expect(monday_shipment.price).to eq(10)
      expect(Shipment.weekly_subtotal(client, sunday)).to be < client.delivery_minimum
      expect(sunday_shipment.delivery_fee).to eq(25)
      expect(sunday_shipment.price).to eq(35)
    end

    it "charged if client doesn't meet minimums and there is no order" do
      order = create(:order, start_date: monday, client: client, bakery: bakery, product: product, daily_item_count: 0)

      monday_shipment = ShipmentCreator.new(order, monday).create!
      sunday_shipment = ShipmentCreator.new(order, sunday).create!

      expect(monday_shipment).to be_nil
      expect(sunday_shipment.delivery_fee).to eq(25)
      expect(sunday_shipment.price).to eq(25)
    end

    it "not charged if client does meet minimums" do
      order = create(:order, start_date: monday, client: client, bakery: bakery, product: product, daily_item_count: 11)

      monday_shipment = ShipmentCreator.new(order, monday).create!
      sunday_shipment = ShipmentCreator.new(order, sunday).create!

      expect(monday_shipment.price).to eq(110)
      expect(Shipment.weekly_subtotal(client, sunday)).to be > client.delivery_minimum
      expect(sunday_shipment.delivery_fee).to eq(0)
      expect(sunday_shipment.price).to eq(110)
    end

    it "not charged if client does meet minimums on Sunday" do
      order = create(:order, start_date: monday, client: client, bakery: bakery, product: product, daily_item_count: 5)

      monday_shipment = ShipmentCreator.new(order, monday).create!
      sunday_shipment = ShipmentCreator.new(order, sunday).create!

      expect(monday_shipment.price).to eq(50)
      expect(sunday_shipment.delivery_fee).to eq(0)
      expect(sunday_shipment.price).to eq(50)
    end
  end
end
