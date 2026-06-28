# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProductGraphDataService do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to(Time.zone.local(2026, 6, 3, 12)) { example.run }
  end

  describe ".digest_last_week" do
    it "updates existing graph data and creates missing rows for the last week" do
      bakery = create(:bakery, id: 1)
      product = create(:product, bakery: bakery, graph_data: {
        dates: ["2026-06-01"],
        amounts: ["1.0"],
        shipped: [1],
        shipments_count: [1]
      })
      create(:product_graph_datum, bakery_id: bakery.id, product_id: product.id, date: Date.new(2026, 6, 1),
                                   amount: 1, shipped: 1, shipment_count: 1)
      create_shipment_item(product, Date.new(2026, 6, 1), quantity: 3, price: 4)
      create_shipment_item(product, Date.new(2026, 6, 2), quantity: 5, price: 6)

      described_class.digest_last_week

      expect_graph_datum(product, Date.new(2026, 6, 1), amount: 12, shipped: 3, shipment_count: 1)
      expect_graph_datum(product, Date.new(2026, 6, 2), amount: 30, shipped: 5, shipment_count: 1)
      expect(product.reload.graph_data["dates"]).to include("2026-06-01", "2026-06-02")
      expect(product.graph_data["amounts"]).to include("12.0", "30.0")
      expect(product.graph_data["shipped"]).to include(3, 5)
    end

    it "skips products with blank graph data" do
      bakery = create(:bakery, id: 1)
      product = create(:product, bakery: bakery)
      create_shipment_item(product, Date.new(2026, 6, 2), quantity: 5, price: 6)

      described_class.digest_last_week

      expect(ProductGraphDatum.where(product_id: product.id)).to be_empty
      expect(product.reload.graph_data).to be_nil
    end

    it "only digests the configured dashboard bakeries" do
      bakery = create(:bakery)
      product = create(:product, bakery: bakery, graph_data: {
        dates: ["2026-06-01"],
        amounts: ["1.0"],
        shipped: [1],
        shipments_count: [1]
      })
      create_shipment_item(product, Date.new(2026, 6, 1), quantity: 3, price: 4)

      described_class.digest_last_week

      expect(ProductGraphDatum.where(product_id: product.id)).to be_empty
    end
  end

  def create_shipment_item(product, date, quantity:, price:)
    shipment = create(:shipment, bakery: product.bakery, date: date)
    create(:shipment_item, bakery: product.bakery, shipment: shipment, product: product, product_quantity: quantity,
                           product_price: price)
  end

  def expect_graph_datum(product, date, amount:, shipped:, shipment_count:)
    datum = ProductGraphDatum.find_by!(product_id: product.id, date: date)
    expect(datum.amount).to eq(amount)
    expect(datum.shipped).to eq(shipped)
    expect(datum.shipment_count).to eq(shipment_count)
  end
end
