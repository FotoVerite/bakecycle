# frozen_string_literal: true

require "rails_helper"

describe OrderCancellationService do
  let(:bakery)  { create(:bakery) }
  let(:client)  { create(:client, bakery: bakery) }
  let(:route)   { create(:route, bakery: bakery) }
  # March 3 2025 is a known Monday — used so weekday assertions are deterministic
  let(:date)    { Date.new(2025, 3, 3) }

  def make_standing_order(for_client: client, monday_qty: 5)
    order = create(:order, bakery: bakery, client: for_client, route: route,
                           order_type: "standing", start_date: date - 1.week, end_date: nil)
    create(:order_item, order: order, bakery: bakery, monday: monday_qty)
    order.reload
  end

  def make_temp_order(for_client: client, with_items: false, zero_items: false)
    temp = create(:temporary_order, bakery: bakery, client: for_client,
                                    route: route, start_date: date)
    create(:order_item, order: temp, bakery: bakery, monday: 3) if with_items
    create(:order_item, order: temp, bakery: bakery, daily_item_count: 0) if zero_items
    temp.reload
  end

  def service(client_ids = [client.id])
    OrderCancellationService.new(bakery, client_ids, date)
  end

  # ── #preview ──────────────────────────────────────────────────────────

  describe "#preview" do
    it "returns will_cancel when a standing order delivers on this day" do
      make_standing_order
      expect(service.preview.first.status).to eq(:will_cancel)
    end

    it "returns no_order when no standing order delivers on this weekday" do
      order = create(:order, bakery: bakery, client: client, route: route,
                             order_type: "standing", start_date: date - 1.week)
      create(:order_item, order: order, bakery: bakery, monday: 0,
                          tuesday: 5, wednesday: 5, thursday: 5, friday: 5, saturday: 5, sunday: 5)
      expect(service.preview.first.status).to eq(:no_order)
    end

    it "returns no_order when the client has no standing order at all" do
      expect(service.preview.first.status).to eq(:no_order)
    end

    it "returns already_cancelled when a zero-quantity temp order exists" do
      make_standing_order
      make_temp_order(zero_items: true)
      expect(service.preview.first.status).to eq(:already_cancelled)
    end

    it "returns needs_confirm when an empty temp order exists" do
      make_standing_order
      make_temp_order
      expect(service.preview.first.status).to eq(:needs_confirm)
    end

    it "returns needs_confirm when a non-zero temp order exists" do
      make_standing_order
      make_temp_order(with_items: true)
      expect(service.preview.first.status).to eq(:needs_confirm)
    end

    it "excludes Internal-channel clients even when explicitly requested" do
      internal = create(:client, bakery: bakery, channel: "Internal")
      make_standing_order(for_client: internal)
      result = OrderCancellationService.new(bakery, [internal.id], date).preview
      expect(result).to be_empty
    end

    it "returns a result for every requested (non-internal) client" do
      second_client = create(:client, bakery: bakery)
      results = OrderCancellationService.new(bakery, [client.id, second_client.id], date).preview
      expect(results.size).to eq(2)
    end

    it "scopes results to the bakery — ignores other bakeries' clients" do
      other_client = create(:client)
      make_standing_order(for_client: other_client)
      result = OrderCancellationService.new(bakery, [other_client.id], date).preview
      expect(result).to be_empty
    end
  end

  # ── #cancel! ──────────────────────────────────────────────────────────

  describe "#cancel!" do
    context "with a will_cancel client" do
      before { make_standing_order }

      it "creates a temporary order with zero-quantity line items" do
        expect { service.cancel! }
          .to change { Order.temporary(date).where(client: client, bakery: bakery).count }.by(1)
        temp = Order.temporary(date).where(client: client, bakery: bakery).first
        expect(temp.order_items.size).to eq(1)
        expect(temp.order_items.first.quantity(date)).to eq(0)
      end

      it "destroys existing shipments for that client and date" do
        create(:shipment, bakery: bakery, client: client, route: route, date: date)
        expect { service.cancel! }
          .to change { Shipment.where(client: client, date: date).count }.by(-1)
      end

      it "does not destroy shipments for other dates" do
        create(:shipment, bakery: bakery, client: client, route: route, date: date + 1.day)
        expect { service.cancel! }
          .not_to(change { Shipment.where(client: client).count })
      end

      it "returns cancelled status" do
        expect(service.cancel!.first.status).to eq(:cancelled)
      end

      it "is idempotent — already_cancelled on a second call" do
        service.cancel!
        result = service.cancel!.first
        expect(result.status).to eq(:already_cancelled)
      end
    end

    context "with a no_order client" do
      before do
        order = create(:order, bakery: bakery, client: client, route: route,
                               order_type: "standing", start_date: date - 1.week)
        create(:order_item, order: order, bakery: bakery, monday: 0,
                            tuesday: 5, wednesday: 5, thursday: 5, friday: 5, saturday: 5, sunday: 5)
      end

      it "does not create any orders" do
        expect { service.cancel! }.not_to(change { Order.count })
      end

      it "returns skipped status" do
        expect(service.cancel!.first.status).to eq(:skipped)
      end
    end

    context "with a needs_confirm client and no force_client_ids" do
      before do
        make_standing_order
        make_temp_order(with_items: true)
      end

      it "does not modify the temp order" do
        expect { service.cancel! }.not_to(change { OrderItem.count })
      end

      it "returns skipped status" do
        expect(service.cancel!.first.status).to eq(:skipped)
      end
    end

    context "with a needs_confirm client included in force_client_ids" do
      before do
        make_standing_order
        make_temp_order(with_items: true)
      end

      it "replaces the temp order's items with zero-quantity overrides" do
        service.cancel!(force_client_ids: [client.id])
        temp = Order.temporary(date).where(client: client, bakery: bakery).first
        expect(temp.order_items.size).to eq(1)
        expect(temp.order_items.first.quantity(date)).to eq(0)
      end

      it "returns cancelled status" do
        result = service.cancel!(force_client_ids: [client.id]).first
        expect(result.status).to eq(:cancelled)
      end
    end
  end
end
