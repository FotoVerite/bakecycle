require 'rails_helper'

describe ProductionRunProjection do
  let(:bakery) { create(:bakery) }
  let(:client) { create(:client, bakery: bakery) }
  let(:sunday) { Time.zone.today.sunday }
  let(:monday) { Time.zone.today.monday }
  let!(:order) do
    create(
      :order,
      :active,
      bakery: bakery,
      client: client,
      total_lead_days: 1,
      order_item_count: 1
    )
  end

  describe '#new' do
    it 'sets products_info with product names and quantities for order items' do
      monday_quantity = order.order_items.map(&:monday).sum
      projector = ProductionRunProjection.new(bakery, sunday)
      expect(monday_quantity).to_not eq(0)
      expect(projector.products_info).to eq(mock_product_info(order, monday_quantity))
    end
  end
end

def mock_product_info(order, order_quantity)
  product = order.products.first
  overbake_quantity = (order_quantity * product.over_bake / 100).ceil
  total_quantity = order_quantity + overbake_quantity
  [OpenStruct.new(
    product: product,
    order_quantity: order_quantity,
    overbake_quantity: overbake_quantity,
    total_quantity: total_quantity
  )]
end
