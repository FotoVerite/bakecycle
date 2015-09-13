require "rails_helper"

describe Shipment do
  let(:bakery) { create(:bakery) }
  let(:shipment) { build(:shipment) }
  let(:today) { Time.zone.today }
  let(:yesterday) { today - 1.day }
  let(:tomorrow) { today + 1.day }

  it "has a shape" do
    expect(shipment).to respond_to(:date)
    expect(shipment).to respond_to(:payment_due_date)
    expect(shipment).to respond_to(:shipment_items)
    expect(shipment).to respond_to(:delivery_fee)
    expect(shipment).to respond_to(:auto_generated)
    expect(shipment).to respond_to(:route_id)
    expect(shipment).to respond_to(:route_name)
    expect(shipment).to respond_to(:route_departure_time)
    expect(shipment).to respond_to(:client_id)
    expect(shipment).to respond_to(:client_name)
    expect(shipment).to respond_to(:client_official_company_name)
    expect(shipment).to respond_to(:client_billing_term)
    expect(shipment).to respond_to(:client_billing_term_days)
    expect(shipment).to respond_to(:client_delivery_address_street_1)
    expect(shipment).to respond_to(:client_delivery_address_street_2)
    expect(shipment).to respond_to(:client_delivery_address_city)
    expect(shipment).to respond_to(:client_delivery_address_state)
    expect(shipment).to respond_to(:client_delivery_address_zipcode)
    expect(shipment).to respond_to(:client_billing_address_street_1)
    expect(shipment).to respond_to(:client_billing_address_street_2)
    expect(shipment).to respond_to(:client_billing_address_city)
    expect(shipment).to respond_to(:client_billing_address_state)
    expect(shipment).to respond_to(:client_billing_address_zipcode)
    expect(shipment).to respond_to(:client_primary_contact_name)
    expect(shipment).to respond_to(:client_primary_contact_phone)
    expect(shipment).to respond_to(:client_notes)
    expect(shipment).to respond_to(:note)
    expect(shipment).to belong_to(:bakery)
  end

  it "has validations" do
    expect(shipment).to validate_presence_of(:date)
    expect(shipment).to validate_presence_of(:payment_due_date)
    expect(shipment).to validate_presence_of(:delivery_fee)
    expect(shipment).to validate_numericality_of(:delivery_fee)
    expect(shipment).to validate_presence_of(:client_id)
    expect(shipment).to validate_presence_of(:route_id)
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
    it "delegates to the shipment searcher" do
      terms = { client_id: 4 }
      expect(ShipmentSearcher).to receive(:search).with(Shipment, terms)
      Shipment.search(terms)
    end
  end

  describe ".latest" do
    it "returns the latest shipments for a client" do
      create(:shipment, date: today - 1)
      shipments = create_list(
        :shipment,
        10,
        date: today
      )
      expect(Shipment.latest(10)).to contain_exactly(*shipments)
    end
  end

  describe ".upcoming" do
    let(:shipment) { create(:shipment, date: today) }

    it "returns upcoming shipments" do
      create(:shipment, date: today - 1.day)
      expect(Shipment.upcoming(today)).to contain_exactly(shipment)
    end
    it "returns upcoming by a date" do
      shipment_2 = create(:shipment, date: today - 1.day)
      expect(Shipment.upcoming(yesterday)).to contain_exactly(shipment, shipment_2)
    end
  end

  describe ".weekly_subtotal" do
    let(:monday) { Date.new(2015, 3, 30) }
    let(:sunday) { Date.new(2015, 4, 5) }

    it "returns the last week of shipments for a client" do
      client = create(:client)
      shipments = [
        create(:shipment, client: client, bakery: client.bakery, date: monday),
        create(:shipment, client: client, bakery: client.bakery, date: sunday)
      ]
      expect(Shipment.weekly_subtotal(client.id, sunday)).to eq(shipments.sum(&:subtotal))
    end
  end

  context "denormalizing" do
    describe "#client=" do
      it "sets client data on shipment" do
        client = build_stubbed(:client, billing_term: :net_30)
        shipment = Shipment.new
        shipment.client = client

        fields = [
          :id, :name, :official_company_name, :billing_term, :billing_term_days, :delivery_address_street_1,
          :delivery_address_street_2, :delivery_address_city, :delivery_address_state,
          :delivery_address_zipcode, :billing_address_street_1, :billing_address_street_2,
          :billing_address_city, :billing_address_state, :billing_address_zipcode,
          :primary_contact_name, :primary_contact_phone, :notes
        ]

        fields.each do |field|
          expect(shipment.send("client_#{field}".to_sym)).to eq(client.send(field))
        end
      end
      it "sets client data when assigned by id" do
        client = create(:client)
        shipment = Shipment.new(client_id: client.id)
        expect(shipment.client_name).to eq(client.name)
      end
    end

    describe "#route=" do
      it "sets route data on shipment" do
        client = build_stubbed(:client)
        route = build_stubbed(:route)
        shipment = Shipment.new

        shipment.client = client
        shipment.route = route

        fields = [:id, :name, :departure_time]

        fields.each do |field|
          expect(shipment.send("route_#{field}".to_sym)).to eq(route.send(field))
        end
      end

      it "clears route data when nil" do
        shipment = Shipment.new(route_name: "Bobys route")
        shipment.route = nil
        expect(shipment.route_name).to be_nil
      end

      it "sets route_name from the name of the related route" do
        route = create(:route, name: "Route1")
        shipment = build(:shipment, route: nil)
        shipment.route_id = route.id
        expect(shipment.route_name).to eq("Route1")
      end
    end

    describe "#route_id=" do
      it 'does nothing the route did\'t change' do
        shipment = build_stubbed(:shipment)
        route_id = shipment.route_id
        expect(Route).to_not receive(:find_by)
        shipment.route_id = route_id
      end
      it "sets route data on shipment" do
        route = create(:route)
        shipment = Shipment.new(route_id: route.id)
        expect(shipment.route_name).to eq(route.name)
      end
    end
  end
end
