require 'rails_helper'

describe OrderItemQuantities do
  let(:start_date) { Time.zone.now }
  let(:bakery) { create(:bakery) }
  let(:client) { create(:client, bakery: bakery) }
  let(:order) { create(:order, :active, bakery: bakery, client: client, order_item_count: 3) }
  let(:order_items) { order.order_items }
  let(:order_item_quantities) { OrderItemQuantities.new(order_items, start_date) }
  let(:product) { order_items.first.product }
  let(:ready_weekday) { (start_date + product.total_lead_days.days).strftime('%A').downcase.to_sym }

  describe '#validate_single_product' do
    it 'sets the product if all order items belong to the same product' do
      expect(order_item_quantities.product).to eq(product)
    end

    it 'raises an argument error if the order items do not belong to the same product' do
      order_item = create(:order_item, bakery: bakery)
      order_items << order_item
      expect { OrderItemQuantities.new(order_items, start_date) }
        .to raise_error(ArgumentError, 'Order Items must belong to the same product')
    end
  end

  describe '#calculate_quantities' do
    it 'calculates the quantities' do
      expected_order = order_items.map(&ready_weekday).sum
      expected_overbake = (expected_order * product.over_bake / 100).ceil
      expected_total = expected_order + expected_overbake

      expect(order_item_quantities.order_quantity).to eq(expected_order)
      expect(order_item_quantities.overbake_quantity).to eq(expected_overbake)
      expect(order_item_quantities.total_quantity).to eq(expected_total)
    end
  end
end
