require "rails_helper"

describe Shipment do
  let(:shipment) { build(:shipment) }

  it "has model attributes" do
    expect(shipment).to respond_to(:date)
    expect(shipment).to respond_to(:payment_due_date)
    expect(shipment).to respond_to(:shipment_items)
    expect(shipment).to respond_to(:delivery_fee)
    expect(shipment).to respond_to(:auto_generated)
    expect(shipment).to respond_to(:route_id)
    expect(shipment).to respond_to(:route_name)
    expect(shipment).to respond_to(:client_id)
    expect(shipment).to respond_to(:client_name)
    expect(shipment).to respond_to(:client_id)
    expect(shipment).to respond_to(:client_name)
    expect(shipment).to respond_to(:client_billing_term)
    expect(shipment).to respond_to(:client_delivery_address_street_1)
    expect(shipment).to respond_to(:client_delivery_address_city)
    expect(shipment).to respond_to(:client_billing_address_street_1)
    expect(shipment).to respond_to(:client_billing_address_city)
    expect(shipment).to respond_to(:client_billing_term_days)
    expect(shipment).to respond_to(:note)
  end

  it "has association" do
    expect(shipment).to belong_to(:bakery)
  end

  it "has validations" do
    expect(shipment).to validate_presence_of(:route_id)
    expect(shipment).to validate_presence_of(:route_name)
    expect(shipment).to validate_presence_of(:date)
    expect(shipment).to validate_presence_of(:payment_due_date)
    expect(shipment).to validate_presence_of(:delivery_fee)
    expect(shipment).to validate_presence_of(:client_id)
    expect(shipment).to validate_presence_of(:client_name)
    expect(shipment).to validate_presence_of(:client_id)
    expect(shipment).to validate_presence_of(:client_name)
    expect(shipment).to validate_presence_of(:client_billing_term)
    expect(shipment).to validate_presence_of(:client_delivery_address_street_1)
    expect(shipment).to validate_presence_of(:client_delivery_address_city)
    expect(shipment).to validate_presence_of(:client_billing_address_street_1)
    expect(shipment).to validate_presence_of(:client_billing_address_city)
    expect(shipment).to validate_presence_of(:client_billing_term_days)
    expect(shipment).to validate_numericality_of(:delivery_fee)
  end

  it "is not a number" do
    expect(build(:shipment, delivery_fee: "not a number")).to_not be_valid
  end

  describe "#set_payment_due_date" do
    it "determines payment due date by reading client billing_term and appending days to date" do
      client = create(:client, billing_term: "net_30")
      shipment = create(:shipment, client: client, date: "2015-01-01")
      expect(shipment.payment_due_date).to eq(shipment.date + 30.days)
    end
  end

  describe "#subtotal" do
    it "sums all the items" do
      shipment.shipment_items = build_list(:shipment_item, 2, product_quantity: 5, product_price: 1.0)
      expect(shipment.subtotal).to eq(10.0)
    end
  end

  describe "#price" do
    it "adds subtotal and delivery fee" do
      shipment.shipment_items = build_list(:shipment_item, 2, product_quantity: 5, product_price: 1.0)
      shipment.delivery_fee = 5
      expect(shipment.subtotal).to eq(10.0)
      expect(shipment.price).to eq(15.0)
    end
  end

  describe ".search" do
    it "returns everything when called without search terms" do
      shipments = create_list(:shipment, 2)
      expect(Shipment.search({})).to include(*shipments)
      nil_values = {
        client_id: nil,
        date_from: nil,
        date_to: nil
      }
      expect(Shipment.search(nil_values)).to include(*shipments)
    end

    it "returns shipments matching a client" do
      shipments = create_list(:shipment, 2)
      shipment = shipments.first
      client_id = shipment.client_id
      expect(Shipment.search(client_id: client_id)).to eq([shipment])
    end

    it "returns shipments after and including a date_from" do
      shipment_1 = create(:shipment, date: Date.today)
      shipment_2 = create(:shipment, date: Date.tomorrow)
      create(:shipment, date: Date.yesterday)

      search = { date_from: Date.today }
      expect(Shipment.search_by_date_from(Date.today)).to contain_exactly(shipment_1, shipment_2)
      expect(Shipment.search(search)).to contain_exactly(shipment_1, shipment_2)
    end

    it "returns shipments before and include a date_to" do
      shipment_1 = create(:shipment, date: Date.today)
      shipment_2 = create(:shipment, date: Date.yesterday)

      search = { date_to: Date.today }
      expect(Shipment.search(search)).to contain_exactly(shipment_1, shipment_2)
    end

    it "allows to search for date ranges" do
      shipment_1 = create(:shipment, date: Date.today)
      create(:shipment, date: Date.yesterday)
      create(:shipment, date: Date.tomorrow)

      search = { date_to: Date.today, date_from: Date.today }
      expect(Shipment.search(search)).to contain_exactly(shipment_1)
    end

    it "allows to search for both client and dates" do
      client = create(:client)
      shipment_1 = create(:shipment, client: client, date: Date.yesterday)
      create(:shipment, date: Date.today)
      create(:shipment, date: Date.tomorrow)
      create(:shipment, client: client, date: Date.tomorrow)

      search = { client_id: client.id, date_from: Date.yesterday, date_to: Date.today }
      expect(Shipment.search(search)).to contain_exactly(shipment_1)
    end
  end

  describe ".recent" do
    it "returns the latest 10 shipments for a client" do
      client = create(:client, name: "Mando")
      create(:shipment)
      create(:shipment, client: client, date: Date.today - 1)
      client_shipments = create_list(:shipment, 10, client: client)

      expect(Shipment.recent(client)).to contain_exactly(*client_shipments)
    end
  end

  describe ".upcoming" do
    it "returns shipments for an order" do
      order = create(:order)
      shipment = create(:shipment, client: order.client, route: order.route, date: Date.today)
      create(:shipment, client: order.client, route: order.route, date: Date.today - 1.day)
      expect(Shipment.upcoming(order)).to contain_exactly(shipment)
    end
  end

  describe "#client=" do
    it "sets client data on shipment" do
      client = build_stubbed(:client, billing_term: :net_30)
      shipment = Shipment.new
      shipment.client = client

      fields = [
        :id,
        :name,
        :dba,
        :billing_term,
        :billing_term_days,
        :delivery_address_street_1,
        :delivery_address_street_2,
        :delivery_address_city,
        :delivery_address_state,
        :delivery_address_zipcode,
        :billing_address_street_1,
        :billing_address_street_2,
        :billing_address_city,
        :billing_address_state,
        :billing_address_zipcode
      ]

      fields.each do |field|
        expect(shipment.send("client_#{field}".to_sym)).to eq(client.send(field))
      end
    end
  end

  describe "#route=" do
    it "sets route data on shipment" do
      client = build_stubbed(:client)
      route = build_stubbed(:route)
      shipment = Shipment.new

      shipment.client = client
      shipment.route = route

      fields = [:id, :name]

      fields.each do |field|
        expect(shipment.send("route_#{field}".to_sym)).to eq(route.send(field))
      end
    end

    it "should set route_name from the name of the related route if that product exists" do
      route = create(:route, name: "Route1")
      shipment = create(:shipment, route: route)
      expect(shipment.route_name).to eq("Route1")
    end
  end
end
