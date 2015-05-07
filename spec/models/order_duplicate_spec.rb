require 'rails_helper'

describe OrderDuplicate do
  let(:order) { create(:order, order_item_count: 2) }

  it 'creates a duplicate of order' do
    order_copy = OrderDuplicate.new(order)
    order_copy_order_items_product_ids = order_copy.order_dup.order_items.map(&:product_id)
    expect(order_copy_order_items_product_ids).to eq(order.order_items.map(&:product_id))
  end
end
