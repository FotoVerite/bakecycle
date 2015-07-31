require "rails_helper"

describe OrderSearcher do
  let(:today) { Time.zone.today }
  let(:yesterday) { today - 1.day }
  let(:tomorrow) { today + 1.day }
  let(:searcher) { OrderSearcher.new(Order) }

  it "returns everything when called without search terms" do
    order = create(:order)
    expect(searcher.search({})).to contain_exactly(order)
  end

  it "returns orders matching a client" do
    create(:order)
    order = create(:order)
    expect(searcher.search(client_id: order.client_id)).to eq([order])
  end

  it "allows searching by a date" do
    order = create(:order, start_date: today)
    create(:order, start_date: tomorrow)
    expect(searcher.search(date: today)).to contain_exactly(order)
  end

  it "allows to search for both client and dates" do
    client = create(:client)
    order = create(:order, client: client, start_date: yesterday)
    create(:order, start_date: today)
    create(:order, start_date: tomorrow)
    create(:order, client: client, start_date: tomorrow)

    search = { client_id: client.id, date: yesterday }
    expect(searcher.search(search)).to contain_exactly(order)
  end

  it "allows us to search by product" do
    order = create(:order)
    create(:order)
    terms = { product_id: order.order_items.first.product_id }
    expect(searcher.search(terms)).to contain_exactly(order)
  end
end
