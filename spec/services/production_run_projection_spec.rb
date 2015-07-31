require "rails_helper"

describe ProductionRunProjection do
  let(:monday) { Time.zone.today.beginning_of_week }
  let(:sunday) { monday - 1.day }
  let(:wednesday) { monday + 2.days }
  let(:thursday) { monday + 3.days }
  let(:friday) { monday + 4.days }
  let(:saturday) { monday + 5.days }
  let(:two_weeks) { saturday + 1.week }

  let(:bakery) { create(:bakery) }
  let(:client) { create(:client, bakery: bakery) }
  let!(:active_order) {
    create(
      :order,
      :active,
      bakery: bakery,
      client: client,
      order_item_count: 3,
      product_total_lead_days: 2,
      product_batch_recipe: true
    )
  }

  let!(:inactive_order) {
    create(:order, :inactive, bakery: bakery, client: client, order_item_count: 3, product_total_lead_days: 2)
  }

  let(:wednesday_quantity) { active_order.order_items.map(&:wednesday).sum }

  before do
    OrderItem.update_all(tuesday: 0)
    active_order.reload
  end

  describe ".products_info" do
    it "sets products_info with product names and quantities for order items" do
      order_product = active_order.products.first

      projector = ProductionRunProjection.new(bakery, monday)
      expect([mock_product_info(order_product, wednesday_quantity)]).to eq(projector.products_info)
    end

    it "does not include a product that should not start on the given date" do
      projector = ProductionRunProjection.new(bakery, sunday)
      expect(projector.products_info).to eq([])
    end

    it "starts products # of lead days before active days, not products that would finish after end day" do
      order = create(:order,  start_date: monday, end_date: thursday, order_item_count: 3, product_total_lead_days: 2)

      tuesday_quantity = order.order_items.map(&:tuesday).sum
      order_product = order.products.first

      projector = ProductionRunProjection.new(order.bakery, sunday)
      expect([mock_product_info(order_product, tuesday_quantity)]).to eq(projector.products_info)

      projector = ProductionRunProjection.new(order.bakery, wednesday)
      expect(projector.products_info).to eq([])
    end

    it "creates recipes info for products that are batch recipes within a given start date to end date" do
      projector = ProductionRunProjection.new(bakery, sunday, saturday)
      expect(projector.order_items.count).to eq(3)
      weekly_quantity = active_order.order_items.map(&:total_quantity).sum

      expect(projector.products_info.first.order_quantity).to eq(weekly_quantity)

      projector = ProductionRunProjection.new(bakery, sunday, two_weeks)
      expect(projector.products_info.first.order_quantity).to eq(weekly_quantity * 2)

      projector = ProductionRunProjection.new(bakery, sunday, monday)
      expect(projector.products_info.first.order_quantity).to eq(wednesday_quantity)
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
