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

    it "includes a sample order's items alongside the standing order's on the same route, not instead of it" do
      client = create(:client, bakery: bakery)
      route = create(:route, bakery: bakery)
      standing_product = create(:product, bakery: bakery, name: "Baguette")
      sample_product = create(:product, bakery: bakery, name: "Sourdough Sample")

      standing = create(:order, bakery: bakery, client: client, route: route, order_type: "standing",
        start_date: start_date - 7.days, order_item_count: 0)
      create(:order_item, bakery: bakery, order: standing, product: standing_product, daily_item_count: 0,
        wednesday: 5)

      sample = create(:sample_order, bakery: bakery, client: client, route: route,
        start_date: start_date, end_date: start_date, order_item_count: 0)
      create(:order_item, bakery: bakery, order: sample, product: sample_product, daily_item_count: 0, wednesday: 1)

      totals = described_class.new(bakery, start_date, start_date).totals

      expect(totals).to contain_exactly([start_date, standing_product, 5], [start_date, sample_product, 1])
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

    it "sums a fleet of several clients, with samples summed alongside (not instead of) their route's winner" do
      product = create(:product, bakery: bakery, name: "Baguette")

      # Client 1: standing + sample of the SAME product on the same route -- quantities should sum.
      c1_standing = create(:order, bakery: bakery, order_type: "standing",
        start_date: start_date - 7.days, order_item_count: 0)
      create(:order_item, bakery: bakery, order: c1_standing, product: product, daily_item_count: 0, wednesday: 5)
      c1_sample = create(:sample_order, bakery: bakery, client: c1_standing.client, route: c1_standing.route,
        start_date: start_date, end_date: start_date, order_item_count: 0)
      create(:order_item, bakery: bakery, order: c1_sample, product: product, daily_item_count: 0, wednesday: 2)

      # Client 2: standing overridden by temporary (no sample) -- only temporary's quantity counts.
      c2_standing = create(:order, bakery: bakery, order_type: "standing",
        start_date: start_date - 7.days, order_item_count: 0)
      create(:order_item, bakery: bakery, order: c2_standing, product: product, daily_item_count: 0, wednesday: 100)
      c2_temp = create(:temporary_order, bakery: bakery, client: c2_standing.client, route: c2_standing.route,
        start_date: start_date, end_date: start_date, order_item_count: 0)
      create(:order_item, bakery: bakery, order: c2_temp, product: product, daily_item_count: 0, wednesday: 3)

      # Client 3: sample only, no standing/temporary at all.
      c3_sample = create(:sample_order, bakery: bakery, start_date: start_date, end_date: start_date,
        order_item_count: 0)
      create(:order_item, bakery: bakery, order: c3_sample, product: product, daily_item_count: 0, wednesday: 1)

      totals = described_class.new(bakery, start_date, start_date).totals

      expect(totals).to eq([[start_date, product, 5 + 2 + 3 + 1]])
    end
  end

  describe "#totals (generated_invoices source)" do
    it "counts a sample-derived shipment's quantity alongside the standing shipment's, even though its price is 0" do
      client = create(:client, bakery: bakery)
      route = create(:route, bakery: bakery)
      standing_product = create(:product, bakery: bakery, name: "Baguette", base_price: 5)
      sample_product = create(:product, bakery: bakery, name: "Sourdough Sample", base_price: 25)

      standing = create(:order, bakery: bakery, client: client, route: route, start_date: start_date,
        order_item_count: 0)
      create(:order_item, bakery: bakery, order: standing, product: standing_product, daily_item_count: 0,
        wednesday: 4)
      sample = create(:sample_order, bakery: bakery, client: client, route: route,
        start_date: start_date, end_date: start_date, order_item_count: 0)
      create(:order_item, bakery: bakery, order: sample, product: sample_product, daily_item_count: 0, wednesday: 3)

      ShipmentCreator.new(standing, start_date).create!
      sample_shipment = ShipmentCreator.new(sample, start_date).create!
      expect(sample_shipment.price).to eq(0) # sanity check the zeroing this test depends on

      totals = described_class.new(bakery, start_date, start_date, source: "generated_invoices").totals

      expect(totals).to contain_exactly([start_date, standing_product, 4], [start_date, sample_product, 3])
    end
  end
end
