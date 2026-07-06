# frozen_string_literal: true

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

    it "subtracts fixed amount discounts from the invoice total" do
      shipment.shipment_items = build_list(:shipment_item, 2, product_quantity: 5, product_price: 1.0)
      shipment.delivery_fee = 5
      shipment.discount_type = "fixed_amount"
      shipment.discount_value = 3

      expect(shipment.discount_base_amount).to eq(10.0)
      expect(shipment.discount_amount).to eq(3)
      expect(shipment.price).to eq(12.0)
    end

    it "calculates percentage discounts from the subtotal" do
      shipment.shipment_items = build_list(:shipment_item, 2, product_quantity: 5, product_price: 1.0)
      shipment.delivery_fee = 5
      shipment.discount_type = "percentage"
      shipment.discount_value = 10

      expect(shipment.discount_base_amount).to eq(10.0)
      expect(shipment.discount_amount).to eq(1)
      expect(shipment.price).to eq(14.0)
    end

    it "does not let discounts make the invoice total negative" do
      shipment.shipment_items = build_list(:shipment_item, 2, product_quantity: 5, product_price: 1.0)
      shipment.delivery_fee = 5
      shipment.discount_type = "fixed_amount"
      shipment.discount_value = 20

      expect(shipment.discount_amount).to eq(15.0)
      expect(shipment.price).to eq(0)
    end

    it "applies a client's default discount to new invoices" do
      client = create(:client, default_discount_type: "percentage", default_discount_value: 10)
      shipment = build(:shipment, client: client, bakery: client.bakery)

      shipment.valid?

      expect(shipment.discount_type).to eq("percentage")
      expect(shipment.discount_value).to eq(10)
    end

    it "requires a discount type when a discount value is entered" do
      shipment.discount_value = 10

      expect(shipment).to be_invalid
      expect(shipment.errors[:discount_type]).to include("must be present when a discount value is entered")
    end

    it "limits percentage discounts to 100" do
      shipment.discount_type = "percentage"
      shipment.discount_value = 101

      expect(shipment).to be_invalid
      expect(shipment.errors[:discount_value]).to include("must be less than or equal to 100 for percentage discounts")
    end

    context "removes daily delivery fee if minimum is updated to needed" do
      let(:route) { create(:route, bakery: bakery) }
      let(:client_with_fee) do
        FactoryBot.create(
          :client,
          :with_delivery_fee,
          bakery: bakery,
          delivery_minimum: 11,
          delivery_fee: 5,
          shipments: [],
          delivery_fee_option: :daily_delivery_fee
        )
      end
      let(:order) { FactoryBot.create(:order, client: client_with_fee, bakery: bakery) }
      let(:shipment) { build(:shipment, bakery: bakery, route: route, client: client_with_fee) }

      it "removes daily delivery fee if minumum is updated to needed" do
        product = create(:product, :with_motherdough, bakery: bakery)
        shipment.shipment_items = build_list(:shipment_item, 2, product: product, product_quantity: 5,
                                                                product_price: 1.0, shipment: nil)
        shipment.delivery_fee = 5
        shipment.order = order
        shipment.save!
        expect(shipment.subtotal).to eq(10.0)
        expect(shipment.price).to eq(15.0)
        shipment.shipment_items.first.update(product_quantity: 6)
        expect(shipment.subtotal).to eq(11.0)
        expect(shipment.price).to eq(16.0)
      end
    end
  end

  describe ".search" do
    it "delegates to the shipment searcher with the current relation" do
      terms = { client_id: 4 }
      expect(ShipmentSearcher).to receive(:search).with(a_kind_of(ActiveRecord::Relation), terms)
      Shipment.search(terms)
    end

    it "preserves a prior bakery scope instead of returning every bakery's shipments" do
      mine = create(:shipment)
      other = create(:shipment)
      expect(mine.bakery_id).not_to eq(other.bakery_id)

      result = Shipment.where(bakery_id: mine.bakery_id).search({})

      expect(result).to contain_exactly(mine)
      expect(result).not_to include(other)
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
      shipment2 = create(:shipment, date: today - 1.day)
      expect(Shipment.upcoming(yesterday)).to contain_exactly(shipment, shipment2)
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

        fields = %i[
          id name official_company_name billing_term billing_term_days delivery_address_street_1
          delivery_address_street_2 delivery_address_city delivery_address_state
          delivery_address_zipcode billing_address_street_1 billing_address_street_2
          billing_address_city billing_address_state billing_address_zipcode
          primary_contact_name primary_contact_phone notes
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

        fields = %i[id name departure_time]

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
        shipment = build(:shipment, route: nil, order: nil)
        shipment.route_id = route.id
        expect(shipment.route_name).to eq("Route1")
      end
    end

    describe "#route_id=" do
      it "does nothing the route did't change" do
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

  describe ".duplicate_invoices" do
    it "returns shipments sharing the same date/client/route" do
      client = create(:client, bakery: bakery)
      route = create(:route, bakery: bakery)
      first = create(:shipment, bakery: bakery, client: client, route: route, date: today)
      second = create(:shipment, bakery: bakery, client: client, route: route, date: today)
      create(:shipment, bakery: bakery, client: client, route: route, date: tomorrow)

      duplicates = described_class.duplicate_invoices(bakery, yesterday..tomorrow)

      expect(duplicates).to contain_exactly(first, second)
    end

    it "returns an empty array when nothing is duplicated" do
      create(:shipment, bakery: bakery, date: today)

      duplicates = described_class.duplicate_invoices(bakery, yesterday..tomorrow)

      expect(duplicates).to be_empty
    end

    it "scopes to the given bakery" do
      other_bakery = create(:bakery)
      client = create(:client, bakery: other_bakery)
      route = create(:route, bakery: other_bakery)
      create(:shipment, bakery: other_bakery, client: client, route: route, date: today)
      create(:shipment, bakery: other_bakery, client: client, route: route, date: today)

      duplicates = described_class.duplicate_invoices(bakery, yesterday..tomorrow)

      expect(duplicates).to be_empty
    end

    it "does not flag a sample order's invoice against a standing/temporary invoice on the same date/client/route" do
      client = create(:client, bakery: bakery)
      route = create(:route, bakery: bakery)
      standing_order = create(:order, bakery: bakery, client: client, route: route, order_item_count: 0)
      sample_order = create(:sample_order, bakery: bakery, client: client, route: route,
                                           start_date: today, end_date: today, order_item_count: 0)
      create(:shipment, bakery: bakery, client: client, route: route, date: today, order: standing_order)
      create(:shipment, bakery: bakery, client: client, route: route, date: today, order: sample_order)

      duplicates = described_class.duplicate_invoices(bakery, yesterday..tomorrow)

      expect(duplicates).to be_empty
    end

    it "still flags duplicates linked to standing/temporary orders" do
      client = create(:client, bakery: bakery)
      route = create(:route, bakery: bakery)
      standing_order = create(:order, bakery: bakery, client: client, route: route, order_item_count: 0)
      temp_order = create(:temporary_order, bakery: bakery, client: client, route: route,
                                            start_date: today, end_date: today, order_item_count: 0)
      first = create(:shipment, bakery: bakery, client: client, route: route, date: today, order: standing_order)
      second = create(:shipment, bakery: bakery, client: client, route: route, date: today, order: temp_order)

      duplicates = described_class.duplicate_invoices(bakery, yesterday..tomorrow)

      expect(duplicates).to contain_exactly(first, second)
    end

    it "picks out exactly the right shipments across a large batch mixing every case at once" do
      # Client 1: real duplicate (standing + temporary, same date/client/route) -- flagged.
      client_1 = create(:client, bakery: bakery)
      route_1 = create(:route, bakery: bakery)
      c1_standing = create(:order, bakery: bakery, client: client_1, route: route_1, order_item_count: 0)
      c1_temp = create(:temporary_order, bakery: bakery, client: client_1, route: route_1,
                                         start_date: today, end_date: today, order_item_count: 0)
      c1_first = create(:shipment, bakery: bakery, client: client_1, route: route_1, date: today, order: c1_standing)
      c1_second = create(:shipment, bakery: bakery, client: client_1, route: route_1, date: today, order: c1_temp)

      # Client 2: standing + sample, same date/client/route -- NOT flagged.
      client_2 = create(:client, bakery: bakery)
      route_2 = create(:route, bakery: bakery)
      c2_standing = create(:order, bakery: bakery, client: client_2, route: route_2, order_item_count: 0)
      c2_sample = create(:sample_order, bakery: bakery, client: client_2, route: route_2,
                                        start_date: today, end_date: today, order_item_count: 0)
      create(:shipment, bakery: bakery, client: client_2, route: route_2, date: today, order: c2_standing)
      create(:shipment, bakery: bakery, client: client_2, route: route_2, date: today, order: c2_sample)

      # Client 3: two manually created shipments (no order at all) sharing date/route -- still flagged.
      client_3 = create(:client, bakery: bakery)
      route_3 = create(:route, bakery: bakery)
      c3_first = create(:shipment, bakery: bakery, client: client_3, route: route_3, date: today, order: nil)
      c3_second = create(:shipment, bakery: bakery, client: client_3, route: route_3, date: today, order: nil)

      # Client 4: single standing shipment, no duplicate at all -- not flagged.
      client_4 = create(:client, bakery: bakery)
      route_4 = create(:route, bakery: bakery)
      c4_standing = create(:order, bakery: bakery, client: client_4, route: route_4, order_item_count: 0)
      create(:shipment, bakery: bakery, client: client_4, route: route_4, date: today, order: c4_standing)

      # Client 5: two sample orders' invoices sharing the same invoice date/client/route (their own
      # order routes differ, which is how two samples for one client on one day are actually allowed
      # to coexist -- the invoices below are pinned to the same route_5 to test the duplicate check
      # itself) -- not flagged, since samples are excluded from the pool entirely and can't flag
      # each other either.
      client_5 = create(:client, bakery: bakery)
      route_5 = create(:route, bakery: bakery)
      c5_sample_a = create(:sample_order, bakery: bakery, client: client_5,
                                          start_date: today, end_date: today, order_item_count: 0)
      c5_sample_b = create(:sample_order, bakery: bakery, client: client_5,
                                          start_date: today, end_date: today, order_item_count: 0)
      create(:shipment, bakery: bakery, client: client_5, route: route_5, date: today, order: c5_sample_a)
      create(:shipment, bakery: bakery, client: client_5, route: route_5, date: today, order: c5_sample_b)

      duplicates = described_class.duplicate_invoices(bakery, yesterday..tomorrow)

      expect(duplicates).to contain_exactly(c1_first, c1_second, c3_first, c3_second)
    end
  end
end
