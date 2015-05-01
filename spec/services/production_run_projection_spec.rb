require 'rails_helper'

describe ProductionRunProjection do
  let(:bakery) { create(:bakery) }
  let(:client) { create(:client, bakery: bakery) }
  let!(:active_order) { create(:order, :active, bakery: bakery, client: client, order_item_count: 3) }
  let!(:inactive_order) { create(:order, :inactive, bakery: bakery, client: client, order_item_count: 3) }

  before do
    OrderItem.update_all(tuesday: 0)
  end

  describe '#new' do
    it 'sets products_info with product names and quantities for order items' do
      monday = Time.zone.today.monday
      wednesday_quantity = active_order.order_items.map(&:wednesday).sum
      projector = ProductionRunProjection.new(bakery, monday)
      order_product = active_order.order_items.first.product

      expect(wednesday_quantity).to_not eq(0)
      expect(projector.products_info).to eq([mock_product_info(order_product, wednesday_quantity)])
    end

    it 'does not include a product that should not start on the given date' do
      sunday = Time.zone.today.sunday
      projector = ProductionRunProjection.new(bakery, sunday)
      expect(projector.products_info).to eq([])
    end
  end

  describe '#collect_order_items' do
    it 'returns only order_items of active orders' do
      monday = Time.zone.today.monday
      projector = ProductionRunProjection.new(bakery, monday)
      expect(projector.order_items).to eq(active_order.order_items)
    end
  end
end
