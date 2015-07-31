require "rails_helper"

describe ShipmentSearcher do
  let(:today) { Time.zone.today }
  let(:yesterday) { today - 1.day }
  let(:tomorrow) { today + 1.day }
  let(:searcher) { ShipmentSearcher.new(Shipment) }

  it "returns everything when called without search terms" do
    shipment = create(:shipment)
    expect(searcher.search({})).to contain_exactly(shipment)
  end

  it "returns shipments matching a client" do
    create(:shipment)
    shipment = create(:shipment)
    expect(searcher.search(client_id: shipment.client_id)).to eq([shipment])
  end

  it "allows searching by a date" do
    shipment = create(:shipment, date: today)
    create(:shipment, date: tomorrow)
    expect(searcher.search(date: today)).to contain_exactly(shipment)
  end

  it "returns shipments after and including a date_from" do
    shipment_1 = create(:shipment, date: today)
    shipment_2 = create(:shipment, date: tomorrow)
    create(:shipment, date: yesterday)

    search = { date_from: today }
    expect(searcher.search(search)).to contain_exactly(shipment_1, shipment_2)
  end

  it "returns shipments before and include a date_to" do
    shipment_1 = create(:shipment, date: today)
    shipment_2 = create(:shipment, date: yesterday)

    search = { date_to: today }
    expect(searcher.search(search)).to contain_exactly(shipment_1, shipment_2)
  end

  it "allows to search for date ranges" do
    shipment = create(:shipment, date: today)
    create(:shipment, date: yesterday)
    create(:shipment, date: tomorrow)

    search = { date_to: today, date_from: today }
    expect(searcher.search(search)).to contain_exactly(shipment)
  end

  it "allows to search for both client and dates" do
    client = create(:client)
    shipment = create(:shipment, client: client, date: yesterday)
    create(:shipment, date: today)
    create(:shipment, date: tomorrow)
    create(:shipment, client: client, date: tomorrow)

    search = { client_id: client.id, date_from: yesterday, date_to: today }
    expect(searcher.search(search)).to contain_exactly(shipment)
  end

  it "allows us to search by product" do
    shipment = create(:shipment)
    create(:shipment)
    terms = { product_id: shipment.shipment_items.first.product_id }
    expect(searcher.search(terms)).to contain_exactly(shipment)
  end
end
