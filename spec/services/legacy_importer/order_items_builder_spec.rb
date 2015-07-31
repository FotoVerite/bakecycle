require "rails_helper"
require "legacy_importer"

describe LegacyImporter::OrderItemsBuilder do
  let(:bakery) { create(:bakery) }
  let(:route) { create(:route, bakery: bakery) }
  let(:client) { create(:client, bakery: bakery, legacy_id: "99") }
  let(:product) { create(:product, bakery: bakery, legacy_id: "2") }

  let(:mock_order_items) do
    double(
      LegacyImporter::OrderItems,
      find_for_order: legacy_order_items,
      find_product: product
    )
  end

  let(:builder) do
    LegacyImporter::OrderItemsBuilder.new(
      bakery: bakery,
      data: legacy_order,
      order_items: mock_order_items
    )
  end

  let(:legacy_order) do
    {
      order_id: 1,
      order_clientid: client.legacy_id,
      order_routeid: route.legacy_id,
      order_type: "standing",
      order_startdate: Time.zone.today,
      order_enddate: Time.zone.tomorrow,
      order_notes: "Go long and throw it down the stairs",
      order_deleted: "N"
    }
  end

  let(:legacy_order_items) do
    [
      { orderitem_day: "mon", orderitem_quantity: 4, orderitem_productid: 2 },
      { orderitem_day: "tue", orderitem_quantity: 8, orderitem_productid: 2 }
    ]
  end

  describe "#make_order_items!" do
    it "creates a recipe out of a legacy_order" do
      item = builder.make_order_items.first
      expect(item).to be_a(OrderItem)
      expect(item.product).to eq(product)
      expect(item.monday).to eq(4)
      expect(item.tuesday).to eq(8)
    end
  end

  context "no product" do
    let(:product) { nil }
    it "ignores items with no products" do
      expect(builder.make_order_items).to be_empty
    end
  end

  context "no quantities" do
    let(:legacy_order_items) do
      [
        { orderitem_day: "mon", orderitem_quantity: 0, orderitem_productid: 2 },
        { orderitem_day: "tue", orderitem_quantity: 0, orderitem_productid: 2 }
      ]
    end
    it "includes items with no quantities" do
      item = builder.make_order_items.first
      expect(item).to be_a(OrderItem)
      expect(item).to be_valid
      expect(item.product).to eq(product)
      expect(item.monday).to eq(0)
    end
  end
end
