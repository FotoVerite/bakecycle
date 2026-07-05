# frozen_string_literal: true

require "rails_helper"

describe ProductTotalsQuery do
  let(:bakery) { create(:bakery) }
  let(:start_date) { Date.new(2026, 6, 3) } # a Wednesday
  let(:end_date) { start_date + 2.days }

  describe "#totals (order_projection source)" do
    it "sums order item quantities per delivery date and product" do
      product = create(:product, bakery: bakery, name: "Croissant")
      order = create(:order, bakery: bakery, start_date: start_date, order_item_count: 0)
      create(:order_item, bakery: bakery, order: order, product: product, daily_item_count: 0, wednesday: 10,
        thursday: 12)

      totals = described_class.new(bakery, start_date, end_date).totals

      expect(totals).to include([start_date, product, 10], [start_date + 1.day, product, 12])
    end

    it "resolves the winning order per (client, route) pair per date, matching Order.active" do
      client = create(:client, bakery: bakery)
      route = create(:route, bakery: bakery)
      product = create(:product, bakery: bakery, name: "Baguette")

      standing = create(:order, bakery: bakery, client: client, route: route, order_type: "standing",
        start_date: start_date - 7.days, order_item_count: 0)
      create(:order_item, bakery: bakery, order: standing, product: product, daily_item_count: 0, wednesday: 5)

      temporary = create(:order, bakery: bakery, client: client, route: route, order_type: "temporary",
        start_date: start_date, end_date: start_date, order_item_count: 0)
      create(:order_item, bakery: bakery, order: temporary, product: product, daily_item_count: 0, wednesday: 40)

      totals = described_class.new(bakery, start_date, start_date).totals

      expect(totals).to eq([[start_date, product, 40]])
    end

    it "excludes orders outside the delivery date's start/end range" do
      product = create(:product, bakery: bakery, name: "Danish")
      order = create(:order, bakery: bakery, start_date: start_date, end_date: start_date, order_item_count: 0)
      create(:order_item, bakery: bakery, order: order, product: product, daily_item_count: 0, wednesday: 10,
        thursday: 10)

      totals = described_class.new(bakery, start_date, end_date).totals

      expect(totals).to eq([[start_date, product, 10]])
    end

    it "only computes queries against this bakery's orders (no cross-tenant results)" do
      other_bakery = create(:bakery)
      other_product = create(:product, bakery: other_bakery, name: "Other Bakery Product")
      other_order = create(:order, bakery: other_bakery, start_date: start_date, order_item_count: 0)
      create(:order_item, bakery: other_bakery, order: other_order, product: other_product, daily_item_count: 0,
        wednesday: 99)

      totals = described_class.new(bakery, start_date, end_date).totals

      expect(totals).to be_empty
    end
  end
end
