require "rails_helper"

describe ProductionRunProjection do
  let(:sunday) { monday - 1.day }
  let(:monday) { Time.zone.today.beginning_of_week }
  let(:tuesday) { monday + 1.days }
  let(:wednesday) { monday + 2.days }
  let(:thursday) { monday + 3.days }
  let(:friday) { monday + 4.days }
  let(:saturday) { monday + 5.days }
  let(:two_weeks) { saturday + 1.week }

  let(:bakery) { create(:bakery) }
  let(:client) { create(:client, bakery: bakery) }
  let(:product) { create(:product, :with_motherdough, bakery: bakery, force_total_lead_days: 2, batch_recipe: true) }

  let!(:active_order) do
    create(
      :order,
      :active,
      bakery: bakery,
      client: client,
      order_item_count: 0
    ).tap do |order|
      create(:order_item, order: order, product: product)
      order.reload
    end
  end

  let!(:inactive_order) do
    create(
      :order,
      :inactive,
      bakery: bakery,
      client: client
    )
  end

  describe ".products_info" do
    it "sets products_info with product names and quantities for order items" do
      projector = ProductionRunProjection.new(bakery, monday)
      count = active_order.order_items.first.wednesday
      expect([mock_product_info(product, count)]).to eq(projector.products_info)
    end

    it "does not include a product that should not start on the given date" do
      active_order.order_items.first.update!(tuesday: 0)
      projector = ProductionRunProjection.new(bakery, sunday)
      expect(projector.products_info).to eq([])
    end

    it "starts products # of lead days before active days, not products that would finish after end day" do
      active_order.update!(start_date: monday, end_date: thursday)
      create(:order_item, order: active_order, product: product)
      active_order.reload

      tuesday_quantity = active_order.order_items.map(&:tuesday).sum

      projector = ProductionRunProjection.new(bakery, sunday)
      expect([mock_product_info(product, tuesday_quantity)]).to eq(projector.products_info)

      projector = ProductionRunProjection.new(bakery, wednesday)
      expect(projector.products_info).to eq([])
    end

    it "creates recipes info for products that are batch recipes within a given start date to end date" do
      projector = ProductionRunProjection.new(bakery, sunday, saturday)
      weekly_quantity = active_order.order_items.first.total_quantity

      expect(projector.products_info.first.order_quantity).to eq(weekly_quantity)

      projector = ProductionRunProjection.new(bakery, sunday, two_weeks)
      expect(projector.products_info.first.order_quantity).to eq(weekly_quantity * 2)

      projector = ProductionRunProjection.new(bakery, sunday, tuesday)
      item = active_order.order_items.first
      quantity = item.tuesday + item.wednesday + item.thursday
      expect(projector.products_info.first.order_quantity).to eq(quantity)
    end
  end
end

def mock_product_info(product, order_quantity)
  overbake_quantity = (order_quantity * product.over_bake / 100).ceil
  total_quantity = order_quantity + overbake_quantity
  MockOrderItemQuantities.new(
    product: product,
    order_quantity: order_quantity,
    overbake_quantity: overbake_quantity,
    total_quantity: total_quantity
  )
end

class MockOrderItemQuantities < OpenStruct
  def ==(other)
    product == other.product &&
      order_quantity == other.order_quantity &&
      overbake_quantity == other.overbake_quantity &&
      total_quantity == other.total_quantity
  end
end
