require "rails_helper"

describe OrderDuplicate do
  let(:order) { create(:order, order_item_count: 2) }

  it "creates a duplicate of order without dates" do
    order_copy = OrderDuplicate.new(order).duplicate
    expect(order_copy).to_not be_persisted
    expect(order_copy.id).to be_nil
    expect(order_copy.start_date).to be_nil
    expect(order_copy.end_date).to be_nil

    order_copy.update!(order_type: "temporary", start_date: Time.zone.today)

    expect(order_copy.id).to_not eq(order.id)
    expect(Order.count).to eq(2)
    expect(order).to eq(Order.find(order.id))

    order_products = order.order_items.pluck(:product_id).sort
    order_copy_products = order_copy.order_items.pluck(:product_id).sort
    expect(order_copy_products).to eq(order_products)
  end
end
