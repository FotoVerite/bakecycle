# frozen_string_literal: true

require "rails_helper"

describe ProductTotalsSnapshot do
  let(:bakery) { create(:bakery) }
  let(:date) { Date.new(2026, 6, 3) } # a Wednesday

  describe ".capture!" do
    it "freezes the order projection with denormalized product names" do
      croissant = create(:product, bakery: bakery, name: "Croissant")
      baguette = create(:product, bakery: bakery, name: "Baguette")
      order = create(:order, bakery: bakery, start_date: date, order_item_count: 0)
      create(:order_item, bakery: bakery, order: order, product: croissant, wednesday: 300)
      create(:order_item, bakery: bakery, order: order, product: croissant, wednesday: 222)
      create(:order_item, bakery: bakery, order: order, product: baguette, wednesday: 12)

      snapshot = described_class.capture!(
        bakery: bakery,
        start_date: date,
        end_date: date,
        source: "order_projection",
        label: ProductTotalsSnapshot::NIGHTLY
      )

      expect(snapshot).to have_attributes(
        source: "order_projection",
        label: "nightly",
        start_date: date,
        end_date: date
      )
      rows = snapshot.rows.order(:product_name).map do |row|
        [row.delivery_date, row.product_name, row.quantity]
      end
      expect(rows).to eq([
                           [date, "Baguette", 12],
                           [date, "Croissant", 522]
                         ])
    end

    it "captures created shipments when the source is generated_invoices" do
      croissant = create(:product, bakery: bakery, name: "Croissant")
      shipment = create(:shipment, bakery: bakery, date: date)
      create(:shipment_item, bakery: bakery, shipment: shipment, product: croissant, product_quantity: 999)

      snapshot = described_class.capture!(
        bakery: bakery,
        start_date: date,
        end_date: date,
        source: "generated_invoices",
        label: ProductTotalsSnapshot::NIGHTLY
      )

      expect(snapshot.rows.pluck(:product_name, :quantity)).to eq([["Croissant", 999]])
    end

    it "records the snapshot even when there is nothing to total" do
      snapshot = described_class.capture!(
        bakery: bakery,
        start_date: date,
        end_date: date,
        source: "order_projection",
        label: ProductTotalsSnapshot::NIGHTLY
      )

      expect(snapshot).to be_persisted
      expect(snapshot.rows).to be_empty
    end

    it "normalizes unknown sources to the order projection" do
      snapshot = described_class.capture!(
        bakery: bakery,
        start_date: date,
        end_date: date,
        source: "bogus",
        label: ProductTotalsSnapshot::NIGHTLY
      )

      expect(snapshot.source).to eq("order_projection")
    end
  end

  it "deletes its rows when destroyed" do
    croissant = create(:product, bakery: bakery, name: "Croissant")
    order = create(:order, bakery: bakery, start_date: date, order_item_count: 0)
    create(:order_item, bakery: bakery, order: order, product: croissant, wednesday: 5)
    snapshot = described_class.capture!(
      bakery: bakery, start_date: date, end_date: date,
      source: "order_projection", label: "nightly"
    )

    expect { snapshot.destroy! }.to change(ProductTotalsSnapshotRow, :count).to(0)
  end
end
