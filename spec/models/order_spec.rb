# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id                      :integer          not null, primary key
#  client_id               :integer          not null
#  route_id                :integer
#  start_date              :date             not null
#  end_date                :date
#  note                    :text             default(""), not null
#  order_type              :string           not null
#  bakery_id               :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  legacy_id               :integer
#  total_lead_days         :integer          not null
#  version_number          :integer          default(0)
#  created_by_user_id      :integer
#  last_updated_by_user_id :integer
#  alert                   :boolean          default(FALSE)
#

require "rails_helper"

describe Order do
  let(:bakery) { create(:bakery) }
  let(:client) { create(:client, bakery: bakery) }
  let(:order) { build(:order, bakery: bakery) }
  let(:today) { Time.zone.today }
  let(:yesterday) { today - 1.day }
  let(:tomorrow) { today + 1.day }
  let(:next_week) { today + 1.week }

  it "has a shape" do
    expect(order).to respond_to(:client)
    expect(order).to respond_to(:route)
    expect(order).to respond_to(:start_date)
    expect(order).to respond_to(:end_date)
    expect(order).to respond_to(:note)
    expect(order).to respond_to(:order_items)
    expect(order).to respond_to(:order_type)
    expect(order).to belong_to(:bakery)
    expect(order).to belong_to(:client)
    expect(order).to belong_to(:route).optional
    expect(order).to belong_to(:bakery)
    expect(order).to belong_to(:client)
    expect(order).to belong_to(:route).optional
    expect(order).to have_many(:order_items)
  end

  it "has validations" do
    expect(order).to validate_presence_of(:client_id)
    expect(order).to validate_presence_of(:route_id)
    expect(order).to validate_presence_of(:start_date)
    expect(order).to validate_presence_of(:order_type)
  end

  context "date validations" do
    it "is invalid if the end date is before the start date" do
      order.start_date = today
      order.end_date = yesterday
      expect(order).to_not be_valid
      expect(order.errors[:end_date].count).to be > 0
    end

    describe "#standing_order_date_can_not_overlap" do
      it "is invalid if two orders overlap" do
        order = create(:order, start_date: today)
        overlaping_order = build(
          :order,
          order_item_count: 0,
          bakery: order.bakery,
          route: order.route,
          client: order.client,
          start_date: today
        )
        expect(overlaping_order).to_not be_valid
        expect(overlaping_order.errors[:start_date].count).to be > 0
      end
    end

    describe "#set_end_date" do
      it "has a starting_date that ends on the same day" do
        temp_order = build(:temporary_order)
        temp_order.valid?
        expect(temp_order.start_date).to eq(temp_order.end_date)
      end
    end
  end

  describe "#total_lead_days" do
    it "returns lead time for order items" do
      order = create(:order, order_item_count: 0, bakery: bakery)
      create(:order_item, order: order, force_total_lead_days: 3, bakery: bakery)
      create(:order_item, order: order, force_total_lead_days: 5, bakery: bakery)
      expect(order.total_lead_days).to eq(5)
    end
  end

  describe "lead days" do
    it "has a total_lead_days of 1 by default" do
      order = create(:order, bakery: bakery, order_item_count: 0)
      expect(order.total_lead_days).to eq(1)
    end

    it "has updates total lead days when order items are created" do
      order = create(:order, bakery: bakery, order_item_count: 0)
      create(:order_item, order: order, force_total_lead_days: 3, bakery: bakery)
      expect(order.total_lead_days).to eq(3)
    end

    it "updates it's total_lead_days when the product is updated" do
      order = create(:order, force_total_lead_days: 3, order_item_count: 1)
      product = order.order_items.first.product
      perform_enqueued_jobs { product.update!(total_lead_days: 8) }
      order.reload
      expect(order.total_lead_days).to eq(8)
    end

    it "updates the total_lead_days when an order item is removed" do
      order = create(:order, force_total_lead_days: 3, order_item_count: 1, bakery: bakery)
      expect(order.total_lead_days).to eq(3)
      order.order_items.destroy_all
      expect(order.total_lead_days).to eq(1)
    end
  end

  describe "#overlapping?" do
    it "returns true if there is an existing overlapping order for the same client and route" do
      route = create(:route, bakery: bakery)
      order = create(:order, bakery: bakery, start_date: today, end_date: tomorrow, route: route, client: client)
      combinations = [
        { start_date: yesterday, end_date: yesterday, result: false },
        { start_date: yesterday, end_date: today, result: true },
        { start_date: yesterday, end_date: tomorrow, result: true },
        { start_date: yesterday, end_date: next_week, result: true },
        { start_date: yesterday, end_date: nil, result: true },
        { start_date: next_week, end_date: nil, result: false },
        { start_date: next_week, end_date: next_week, result: false },
        { start_date: today, end_date: today, result: true },
        { start_date: today, end_date: tomorrow, result: true },
        { start_date: today, end_date: next_week, result: true },
        { start_date: today, end_date: nil, result: true },
        { start_date: tomorrow, end_date: tomorrow, result: true },
        { start_date: tomorrow, end_date: next_week, result: true },
        { start_date: tomorrow, end_date: nil, result: true }
      ]

      combinations.each do |combo|
        start_date, end_date, result = combo.values_at(:start_date, :end_date, :result)
        order = build_stubbed(
          :order,
          bakery: order.bakery,
          route: route, client: client,
          start_date: start_date,
          end_date: end_date
        )
        msg = "expected start_date of #{start_date}, & end_date of #{end_date || 'nil'} to have overlapping? #{result}"
        expect(order.overlapping?).to eq(result), msg
      end
    end

    it "returns true if there is an existing overlapping order for the same client and route with no end date" do
      client = create(:client)
      route = create(:route)
      order = create(:order, start_date: today, end_date: nil, route: route, client: client)

      combinations = [
        { start_date: yesterday, end_date: yesterday, result: false },
        { start_date: yesterday, end_date: today, result: true },
        { start_date: yesterday, end_date: tomorrow, result: true },
        { start_date: yesterday, end_date: nil, result: true },
        { start_date: today, end_date: today, result: true },
        { start_date: today, end_date: tomorrow, result: true },
        { start_date: today, end_date: nil, result: true },
        { start_date: tomorrow, end_date: tomorrow, result: true },
        { start_date: tomorrow, end_date: nil, result: true }
      ]

      combinations.each do |combo|
        start_date, end_date, result = combo.values_at(:start_date, :end_date, :result)
        order = build_stubbed(
          :order,
          bakery: order.bakery,
          route: route,
          client: client,
          start_date: start_date,
          end_date: end_date
        )
        msg = "expected start_date of #{start_date}, & end_date of #{end_date || 'nil'} to have overlapping? #{result}"
        expect(order.overlapping?).to eq(result), msg
      end
    end

    it "returns false if there are overlapping orders for other clients and temporary orders" do
      order = create(:order, bakery: bakery, start_date: today, end_date: today, order_item_count: 0)
      create(:temporary_order, bakery: bakery, route: order.route, client: order.client, start_date: today,
                               order_item_count: 0)
      create(:order, bakery: bakery, route: order.route, start_date: today, order_item_count: 0)
      create(:order, bakery: bakery, client: order.client, start_date: today, order_item_count: 0)
      expect(order).to_not be_overlapping
    end

    it "lets temporary orders get away with not having an end date" do
      order = create(:temporary_order, start_date: today)
      not_overlapping = create(:temporary_order, start_date: tomorrow, client: order.client, route: order.route)
      expect(not_overlapping).to_not be_overlapping
      expect(order).to_not be_overlapping
    end

    it "returns false if it overlaps with itself" do
      order = create(:order, start_date: today, end_date: today)
      expect(order).to_not be_overlapping
    end
  end

  describe "#overridable_order" do
    it "returns an order that can be overridden if found - with nil end date" do
      order.destroy
      route = create(:route, bakery: bakery)
      old_order = create(:order, bakery: bakery, start_date: today, end_date: nil, route: route, client: client)
      combinations = [
        { start_date: yesterday, end_date: yesterday, result: false },
        { start_date: yesterday, end_date: today, result: true },
        { start_date: yesterday, end_date: tomorrow, result: true },
        { start_date: yesterday, end_date: next_week, result: true },
        { start_date: yesterday, end_date: nil, result: true },
        { start_date: next_week, end_date: nil, result: false },
        { start_date: today, end_date: today, result: false },
        { start_date: today, end_date: tomorrow, result: false },
        { start_date: today, end_date: next_week, result: false },
        { start_date: today, end_date: nil, result: false },
        { start_date: tomorrow, end_date: tomorrow, result: false },
        { start_date: tomorrow, end_date: next_week, result: false },
        { start_date: tomorrow, end_date: nil, result: false }
      ]

      combinations.each do |combo|
        start_date, end_date, result = combo.values_at(:start_date, :end_date, :result)
        old_order.update(start_date: start_date, end_date: end_date)
        new_order = build_stubbed(:order,
                                  bakery: bakery,
                                  start_date: today,
                                  end_date: nil,
                                  route: route,
                                  client: client)
        expect(new_order.overridable_order.present?).to eq(result)
      end
    end

    it "returns an order that can be overridden if found - with end date" do
      order.destroy
      route = create(:route, bakery: bakery)
      old_order = create(
        :order,
        bakery: bakery,
        start_date: today,
        end_date: nil,
        route: route,
        client: client
      )

      combinations = [
        { start_date: yesterday, end_date: yesterday, result: false },
        { start_date: yesterday, end_date: today, result: true },
        { start_date: yesterday, end_date: tomorrow, result: true },
        { start_date: yesterday, end_date: next_week, result: false },
        { start_date: yesterday, end_date: nil, result: true },
        { start_date: next_week, end_date: nil, result: false },
        { start_date: today, end_date: today, result: false },
        { start_date: today, end_date: tomorrow, result: false },
        { start_date: today, end_date: next_week, result: false },
        { start_date: today, end_date: nil, result: false },
        { start_date: tomorrow, end_date: tomorrow, result: false },
        { start_date: tomorrow, end_date: next_week, result: false },
        { start_date: tomorrow, end_date: nil, result: false }
      ]

      combinations.each do |combo|
        start_date, end_date, result = combo.values_at(:start_date, :end_date, :result)
        old_order.update(start_date: start_date, end_date: end_date)
        new_order = build_stubbed(
          :order,
          bakery: bakery,
          start_date: today,
          end_date: tomorrow,
          route: route,
          client: client
        )
        expect(new_order.overridable_order.present?).to eq(result)
      end
    end
  end

  describe ".temporary" do
    it "returns all temporary orders on a date" do
      temp_order = create(:temporary_order, start_date: today)
      create(:temporary_order, start_date: today + 1.day)
      create(:order)

      expect(Order.temporary(today)).to contain_exactly(temp_order)
    end
  end

  describe ".standing" do
    it "returns all standing orders active on a day" do
      order = create(:order, start_date: today, end_date: today, order_item_count: 0)
      order2 = create(:order, start_date: yesterday, end_date: today + 1.day, order_item_count: 0)
      order3 = create(:order, start_date: yesterday, end_date: nil, order_item_count: 0)
      create(:order, start_date: yesterday, end_date: yesterday, order_item_count: 0)
      create(:temporary_order, start_date: today, order_item_count: 0)

      expect(Order.standing(today)).to contain_exactly(order, order2, order3)
    end
  end

  describe ".order_by_active" do
    it "sorts by end date with open ended orders treated as active today" do
      old_order = create(:order, start_date: yesterday, end_date: yesterday, order_item_count: 0)
      active_order = create(:order, start_date: yesterday, end_date: nil, order_item_count: 0)
      future_order = create(:order, start_date: yesterday, end_date: tomorrow, order_item_count: 0)

      expect(Order.where(id: [old_order, active_order, future_order]).order_by_active).to eq(
        [future_order, active_order, old_order]
      )
    end
  end

  describe ".active" do
    it "returns all active orders for a date" do
      order = create(:order, start_date: yesterday, order_item_count: 0)
      client = order.client
      temp_order = create(:temporary_order, start_date: today, client: client, route: order.route, order_item_count: 0)
      different_route = create(:order, start_date: yesterday, client: client, order_item_count: 0)
      expect(Order.active(yesterday)).to contain_exactly(order, different_route)
      expect(Order.active(today)).to contain_exactly(temp_order, different_route)
    end

    it "allows scoping to clients" do
      create(:order, start_date: yesterday)
      order = create(:order, start_date: yesterday)
      client = order.client
      expect(client.orders.active(today)).to contain_exactly(order)
    end

    it "always includes a sample order alongside a standing order sharing the same route" do
      standing = create(:order, start_date: yesterday, order_item_count: 0)
      sample = create(
        :sample_order, start_date: today, end_date: today,
        client: standing.client, route: standing.route, order_item_count: 0
      )

      expect(Order.active(today)).to contain_exactly(standing, sample)
    end

    it "includes a sample order alongside whichever of standing/temporary wins the tie-break" do
      standing = create(:order, start_date: yesterday, order_item_count: 0)
      temporary = create(
        :temporary_order, start_date: today, end_date: today,
        client: standing.client, route: standing.route, order_item_count: 0
      )
      sample = create(
        :sample_order, start_date: today, end_date: today,
        client: standing.client, route: standing.route, order_item_count: 0
      )

      expect(Order.active(today)).to contain_exactly(temporary, sample)
    end

    it "resolves a whole fleet of clients correctly, each with its own mix of order types" do
      # Client A: standing only, no override, no sample -- baseline, must survive untouched.
      client_a_standing = create(:order, bakery: bakery, start_date: yesterday, order_item_count: 0)

      # Client B: standing + a temporary override on the same route/date, no sample.
      client_b_standing = create(:order, bakery: bakery, start_date: yesterday, order_item_count: 0)
      client_b_temp = create(
        :temporary_order, bakery: bakery, start_date: today, end_date: today,
        client: client_b_standing.client, route: client_b_standing.route, order_item_count: 0
      )

      # Client C: standing + a sample sharing the same route -- both must survive.
      client_c_standing = create(:order, bakery: bakery, start_date: yesterday, order_item_count: 0)
      client_c_sample = create(
        :sample_order, bakery: bakery, start_date: today, end_date: today,
        client: client_c_standing.client, route: client_c_standing.route, order_item_count: 0
      )

      # Client D: standing + temporary override + sample, all on the same route/date --
      # temporary wins the standing/temporary tie-break, sample rides alongside regardless.
      client_d_standing = create(:order, bakery: bakery, start_date: yesterday, order_item_count: 0)
      client_d_temp = create(
        :temporary_order, bakery: bakery, start_date: today, end_date: today,
        client: client_d_standing.client, route: client_d_standing.route, order_item_count: 0
      )
      client_d_sample = create(
        :sample_order, bakery: bakery, start_date: today, end_date: today,
        client: client_d_standing.client, route: client_d_standing.route, order_item_count: 0
      )

      # Client E: two samples on two different routes, no standing/temporary at all.
      client_e = create(:client, bakery: bakery)
      client_e_sample_route_1 = create(
        :sample_order, bakery: bakery, client: client_e, start_date: today, end_date: today, order_item_count: 0
      )
      client_e_sample_route_2 = create(
        :sample_order, bakery: bakery, client: client_e, start_date: today, end_date: today, order_item_count: 0
      )

      # Client F: standing order that expired yesterday -- must not appear today at all.
      create(:order, bakery: bakery, start_date: yesterday - 1.week, end_date: yesterday, order_item_count: 0)

      expect(Order.active(today)).to contain_exactly(
        client_a_standing,
        client_b_temp,
        client_c_standing, client_c_sample,
        client_d_temp, client_d_sample,
        client_e_sample_route_1, client_e_sample_route_2
      )
    end

    it "never lets a null route_id collapse orders across different clients" do
      client_x = create(:order, bakery: bakery, start_date: yesterday, order_item_count: 0)
      client_y = create(:order, bakery: bakery, start_date: yesterday, order_item_count: 0)
      client_x.update_column(:route_id, nil)
      client_y.update_column(:route_id, nil)

      expect(Order.active(today)).to contain_exactly(client_x, client_y)
    end
  end

  describe "#still_in_use / .still_in_use" do
    it "treats a sample order the same as a temporary order: in use only up to its (single) start date" do
      future_sample = build_stubbed(:sample_order, start_date: tomorrow, end_date: tomorrow)
      today_sample = build_stubbed(:sample_order, start_date: today, end_date: today)
      past_sample = build_stubbed(:sample_order, start_date: yesterday, end_date: yesterday)

      expect(future_sample.still_in_use).to be true
      expect(today_sample.still_in_use).to be true
      expect(past_sample.still_in_use).to be false
    end

    it "matches the scope to the instance method across a mixed fleet" do
      standing_open = create(:order, start_date: yesterday, end_date: nil, order_item_count: 0)
      standing_expired = create(:order, start_date: yesterday - 1.week, end_date: yesterday, order_item_count: 0)
      temp_future = create(:temporary_order, start_date: tomorrow, end_date: tomorrow, order_item_count: 0)
      temp_past = create(:temporary_order, start_date: yesterday, end_date: yesterday, order_item_count: 0)
      sample_future = create(:sample_order, start_date: tomorrow, end_date: tomorrow, order_item_count: 0)
      sample_past = create(:sample_order, start_date: yesterday, end_date: yesterday, order_item_count: 0)

      all_orders = [standing_open, standing_expired, temp_future, temp_past, sample_future, sample_past]
      expected_in_use = all_orders.select(&:still_in_use)

      expect(Order.where(id: all_orders).still_in_use).to contain_exactly(*expected_in_use)
      expect(expected_in_use).to contain_exactly(standing_open, temp_future, sample_future)
    end
  end

  describe ".production_date" do
    it "runs" do
      Order.production_date(Time.zone.today)
    end
  end

  describe "#no_outstanding_shipments?" do
    describe "order that goes to production today" do
      let(:order) {
        create(:order, start_date: yesterday, force_total_lead_days: 1, order_item_count: 1, bakery: bakery)
      }

      it "returns true if it is before kickoff" do
        create(:shipment, date: Time.zone.today, order: order, bakery: bakery)
        Timecop.freeze(Time.zone.now.change(hour: 9)) do
          expect(order.no_outstanding_shipments?).to be_truthy
        end
      end

      it "returns false if it's after kickoff" do
        Timecop.freeze(Time.zone.now.change(hour: 15)) do
          expect(order.no_outstanding_shipments?).to be_falsy
        end
      end

      it "returns false after kickoff if older shipment is missing" do
        create(:shipment, date: Time.zone.today, order: order, bakery: bakery)
        Timecop.freeze(Time.zone.now.change(hour: 15)) do
          expect(order.no_outstanding_shipments?).to be_falsy
        end
      end

      it "returns false after kickoff if latest shipment is missing" do
        create(:shipment, date: Time.zone.today, order: order, bakery: bakery)
        Timecop.freeze(Time.zone.now.change(hour: 15)) do
          expect(order.no_outstanding_shipments?).to be_falsy
        end
      end

      it "returns true after kickoff if there is are shipments" do
        create(:shipment, date: Time.zone.today, order: order, bakery: bakery)
        create(:shipment, date: Time.zone.today + 1.day, order: order, bakery: bakery)
        Timecop.freeze(Time.zone.now.change(hour: 15)) do
          expect(order.no_outstanding_shipments?).to be_truthy
        end
      end

      it "returns true after kickoff if there is the order is active but has no items for that day." do
        order.order_items.update_all(Time.zone.today.strftime("%A").downcase => 0)
        create(:shipment, date: Time.zone.today + 1.day, order: order, bakery: bakery)
        Timecop.freeze(Time.zone.now.change(hour: 15)) do
          expect(order.no_outstanding_shipments?).to be_truthy
        end
      end
    end

    describe "order that has a total_lead_days of 2" do
      let(:order) {
        create(:order, start_date: yesterday, force_total_lead_days: 2, order_item_count: 1, bakery: bakery)
      }

      it "returns true if it is before kickoff" do
        create(:shipment, date: Time.zone.today, order: order, bakery: bakery)
        create(:shipment, date: Time.zone.today + 1.day, order: order, bakery: bakery)
        create(:shipment, date: Time.zone.today + 2.days, order: order, bakery: bakery)
        Timecop.freeze(Time.zone.now.change(hour: 9)) do
          expect(order.no_outstanding_shipments?).to be_truthy
        end
      end

      it "returns false after kickoff if older shipment is missing" do
        create(:shipment, date: Time.zone.today, order: order, bakery: bakery)
        create(:shipment, date: Time.zone.today + 2.days, order: order, bakery: bakery)
        Timecop.freeze(Time.zone.now.change(hour: 15)) do
          expect(order.no_outstanding_shipments?).to be_falsy
        end
      end

      it "returns false after kickoff if latest shipment is missing" do
        create(:shipment, date: Time.zone.today, order: order, bakery: bakery)
        create(:shipment, date: Time.zone.today + 1.day, order: order, bakery: bakery)
        Timecop.freeze(Time.zone.now.change(hour: 15)) do
          expect(order.no_outstanding_shipments?).to be_falsy
        end
      end

      it "returns true after kickoff if there is are shipments" do
        create(:shipment, date: Time.zone.today, order: order, bakery: bakery)
        create(:shipment, date: Time.zone.today + 1.day, order: order, bakery: bakery)
        create(:shipment, date: Time.zone.today + 2.days, order: order, bakery: bakery)
        create(:shipment, date: Time.zone.today, order: order, bakery: bakery)
        Timecop.freeze(Time.zone.now.change(hour: 15)) do
          expect(order.no_outstanding_shipments?).to be_truthy
        end
      end
    end

    describe "inactive orders" do
      it "returns true if the order is inactive" do
        order = create(:order, :inactive)
        expect(order.no_outstanding_shipments?).to be_truthy
      end
    end
  end

  describe ".missing_shipment_dates_for" do
    let(:bakery) { create(:bakery) }
    let(:yesterday) { Time.zone.today - 1.day }
    let(:today) { Time.zone.today }

    it "returns empty hash if orders list is empty" do
      expect(described_class.missing_shipment_dates_for([])).to eq({})
    end

    it "matches #missing_shipment_dates for single order with missing invoice" do
      Timecop.freeze(Time.zone.now.change(hour: 15)) do
        order = create(:order, bakery: bakery, start_date: yesterday, force_total_lead_days: 1,
                               order_item_count: 1)
        missing_via_instance = order.missing_shipment_dates
        missing_via_batch = described_class.missing_shipment_dates_for([order])

        expect(missing_via_batch[order.id]).to eq(missing_via_instance)
      end
    end

    it "matches #missing_shipment_dates for multiple orders" do
      Timecop.freeze(Time.zone.now.change(hour: 15)) do
        order1 = create(:order, bakery: bakery, start_date: yesterday, force_total_lead_days: 1,
                                order_item_count: 1)
        order2 = create(:order, bakery: bakery, start_date: yesterday, force_total_lead_days: 2,
                                order_item_count: 1)

        missing_via_batch = described_class.missing_shipment_dates_for([order1, order2])

        expect(missing_via_batch[order1.id]).to eq(order1.missing_shipment_dates)
        expect(missing_via_batch[order2.id]).to eq(order2.missing_shipment_dates)
      end
    end

    it "returns empty hash entries for orders with no missing shipments" do
      order = create(:order, bakery: bakery, start_date: yesterday, force_total_lead_days: 1,
                             order_item_count: 1)
      create(:shipment, date: today, order: order, bakery: bakery)
      create(:shipment, date: today + 1.day, order: order, bakery: bakery)

      missing_via_batch = described_class.missing_shipment_dates_for([order])

      expect(missing_via_batch[order.id]).to be_nil
    end

    it "handles orders with no items for a given day" do
      Timecop.freeze(Time.zone.now.change(hour: 15)) do
        order = create(:order, bakery: bakery, start_date: yesterday, force_total_lead_days: 1,
                               order_item_count: 1)
        order.order_items.update_all(today.strftime("%A").downcase => 0)
        create(:shipment, date: today + 1.day, order: order, bakery: bakery)

        missing_via_batch = described_class.missing_shipment_dates_for([order])

        expect(missing_via_batch[order.id]).to be_nil
      end
    end

    it "treats a temporary order as the active order for its delivery date" do
      Timecop.freeze(Time.zone.local(2026, 6, 1, 15)) do
        standing = create(
          :order,
          bakery: bakery,
          start_date: Time.zone.today - 1.week,
          force_total_lead_days: 1,
          order_item_count: 1,
          daily_item_count: 1
        )
        temporary = create(
          :temporary_order,
          bakery: bakery,
          client: standing.client,
          route: standing.route,
          start_date: Time.zone.today,
          order_item_count: 1,
          daily_item_count: 0
        )

        missing_dates = described_class.missing_shipment_dates_for([standing])

        expect(temporary).to be_persisted
        expect(missing_dates[standing.id]).to eq([Time.zone.today + 1.day])
        expect(missing_dates[standing.id]).to eq(standing.missing_shipment_dates)
      end
    end

    it "agrees with #missing_shipment_dates for every order in a fleet mixing standing/temporary/sample "\
       "on shared routes" do
      Timecop.freeze(Time.zone.now.change(hour: 15)) do
        standing = create(:order, bakery: bakery, start_date: yesterday, force_total_lead_days: 1,
          order_item_count: 1)
        temporary = create(
          :temporary_order, bakery: bakery, client: standing.client, route: standing.route,
          start_date: today, end_date: today, force_total_lead_days: 1, order_item_count: 1
        )
        sample = create(
          :sample_order, bakery: bakery, client: standing.client, route: standing.route,
          start_date: today, end_date: today, force_total_lead_days: 1, order_item_count: 1
        )
        unrelated_standing = create(:order, bakery: bakery, start_date: yesterday, force_total_lead_days: 1,
          order_item_count: 1)

        orders = [standing, temporary, sample, unrelated_standing]
        missing_via_batch = described_class.missing_shipment_dates_for(orders)

        orders.each do |order|
          expect(missing_via_batch[order.id]).to eq(order.missing_shipment_dates), "mismatch for #{order.order_type}"
        end
      end
    end
  end
end
