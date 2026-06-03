require "rails_helper"

RSpec.describe ShipmentGraphDataService do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to(Time.zone.local(2026, 6, 3, 12)) { example.run }
  end

  describe ".generate" do
    it "rebuilds shipment graph data for each bakery from first shipment date through yesterday" do
      bakery = create(:bakery)
      other_bakery = create(:bakery)
      create(:shipment_graph_datum, bakery_id: bakery.id, date: Date.new(2026, 5, 1), amount: 99, product_count: 99)
      create_shipment_with_item(bakery, Date.new(2026, 6, 1), quantity: 2, price: 3)
      create_shipment_with_item(bakery, Date.new(2026, 6, 2), quantity: 4, price: 5)
      create_shipment_with_item(other_bakery, Date.new(2026, 6, 2), quantity: 7, price: 11)

      described_class.generate

      expect(ShipmentGraphDatum.count).to eq(3)
      expect_graph_datum(bakery, Date.new(2026, 6, 1), amount: 6, product_count: 2)
      expect_graph_datum(bakery, Date.new(2026, 6, 2), amount: 20, product_count: 4)
      expect_graph_datum(other_bakery, Date.new(2026, 6, 2), amount: 77, product_count: 7)
      expect(bakery.reload.graph_data).to include(
        "dates" => ["2026-06-01", "2026-06-02"],
        "amounts" => ["6.0", "20.0"],
        "product_counts" => [2, 4]
      )
    end

    it "skips bakeries with no shipments" do
      bakery = create(:bakery)

      described_class.generate

      expect(ShipmentGraphDatum.where(bakery_id: bakery.id)).to be_empty
      expect(bakery.reload.graph_data).to be_nil
    end
  end

  describe ".digest_last_week" do
    it "updates existing graph data and creates missing rows for the last week" do
      bakery = create(:bakery, graph_data: {
        dates: ["2026-06-01"],
        amounts: ["1.0"],
        product_counts: [1]
      })
      create(:shipment_graph_datum, bakery_id: bakery.id, date: Date.new(2026, 6, 1), amount: 1, product_count: 1)
      create_shipment_with_item(bakery, Date.new(2026, 6, 1), quantity: 3, price: 4)
      create_shipment_with_item(bakery, Date.new(2026, 6, 2), quantity: 5, price: 6)

      described_class.digest_last_week

      expect_graph_datum(bakery, Date.new(2026, 6, 1), amount: 12, product_count: 3)
      expect_graph_datum(bakery, Date.new(2026, 6, 2), amount: 30, product_count: 5)
      expect(bakery.reload.graph_data["dates"]).to include("2026-06-01", "2026-06-02")
      expect(bakery.graph_data["amounts"]).to include("12.0", "30.0")
      expect(bakery.graph_data["product_counts"]).to include(3, 5)
    end

    it "skips bakeries with blank graph data" do
      bakery = create(:bakery)
      create_shipment_with_item(bakery, Date.new(2026, 6, 2), quantity: 5, price: 6)

      described_class.digest_last_week

      expect(ShipmentGraphDatum.where(bakery_id: bakery.id)).to be_empty
      expect(bakery.reload.graph_data).to be_nil
    end
  end

  def create_shipment_with_item(bakery, date, quantity:, price:)
    product = create(:product, :with_motherdough, bakery: bakery)
    shipment = create(:shipment, bakery: bakery, date: date)
    create(:shipment_item, bakery: bakery, shipment: shipment, product: product, product_quantity: quantity, product_price: price)
    shipment
  end

  def expect_graph_datum(bakery, date, amount:, product_count:)
    datum = ShipmentGraphDatum.find_by!(bakery_id: bakery.id, date: date)
    expect(datum.amount).to eq(amount)
    expect(datum.product_count).to eq(product_count)
  end
end
