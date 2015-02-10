require "rails_helper"

describe Order do
  let(:order) { build(:order) }

  it "has model attributes" do
    expect(order).to respond_to(:client)
    expect(order).to respond_to(:route)
    expect(order).to respond_to(:start_date)
    expect(order).to respond_to(:end_date)
    expect(order).to respond_to(:note)
    expect(order).to respond_to(:order_items)
    expect(order).to respond_to(:order_type)
  end

  it "has association" do
    expect(order).to belong_to(:bakery)
  end

  it "has validations" do
    expect(order).to belong_to(:client)
    expect(order).to validate_presence_of(:client_id)
    expect(order).to belong_to(:route)
    expect(order).to validate_presence_of(:route_id)
    expect(order).to validate_presence_of(:start_date)
    expect(order).to validate_presence_of(:order_items).with_message(/You must choose a product before saving/)
    expect(order).to validate_presence_of(:order_type)
  end

  describe "#set_end_date" do
    it "has a starting_date that ends on the same day" do
      temp_order = build(:temporary_order)
      temp_order.valid?
      expect(temp_order.start_date).to eq(temp_order.end_date)
    end
  end

  describe "#lead_time" do
    it "returns lead time for order items" do
      motherdough = create(:recipe_motherdough, lead_days: 5)
      inclusion = create(:recipe_inclusion, lead_days: 3)
      product_1 = create(:product, inclusion: inclusion)
      product_2 = create(:product, motherdough: motherdough)

      order = create(:order)
      order.order_items << build(:order_item, order: nil, product: product_1)
      order.order_items << build(:order_item, order: nil, product: product_2)

      expect(order.lead_time).to eq(5)
    end
  end
end
