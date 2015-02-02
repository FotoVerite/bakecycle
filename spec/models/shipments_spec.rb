require "rails_helper"

describe Shipment do
  let(:shipment) { build(:shipment) }

  it "has model attributes" do
    expect(shipment).to respond_to(:client)
    expect(shipment).to respond_to(:route)
    expect(shipment).to respond_to(:date)
    expect(shipment).to respond_to(:payment_due_date)
    expect(shipment).to respond_to(:shipment_items)
  end

  it "has association" do
    expect(shipment).to belong_to(:client)
    expect(shipment).to belong_to(:route)
    expect(shipment).to belong_to(:bakery)
  end

  it "has validations" do
    expect(shipment).to validate_presence_of(:route)
    expect(shipment).to validate_presence_of(:client)
    expect(shipment).to validate_presence_of(:date)
    expect(shipment).to validate_presence_of(:payment_due_date)
  end

  describe "#set_payment_due_date" do
    it "determines payment due date by reading client billing_term and appending days to date" do
      client = create(:client, billing_term: "net_30")
      shipment_with_date = create(:shipment, client: client, date: "2015-01-01")
      expect(shipment_with_date.payment_due_date).to eq(shipment_with_date.date + 30.days)
    end
  end

  describe "#price" do
    it "sums all the items" do
      shipment.shipment_items = build_list(:shipment_item, 2, product_quantity: 5, product_price: 1.0)
      expect(shipment.price).to eq(10.0)
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
      client_order = shipments.first
      client_id = client_order.client.id
      expect(Shipment.search(client_id: client_id)).to eq([client_order])
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

  describe ".client_recent_shipment" do
    it "returns the latest 10 shipments for a client" do
      client = create(:client, name: "Mando")

      random_shipments = create_list(:shipment, 10)
      client_shipment_1 = create(:shipment, client: client, date: Date.today - 2)
      client_shipment_2 = create(:shipment, client: client, date: Date.today - 1)
      client_shipments = create_list(:shipment, 10, client: client)

      expect(Shipment.recent_shipments(client)).to contain_exactly(*client_shipments)
      expect(Shipment.recent_shipments(client)).to_not include(client_shipment_1, client_shipment_2)
      expect(Shipment.recent_shipments(client)).to_not include(*random_shipments)
    end
  end
end
