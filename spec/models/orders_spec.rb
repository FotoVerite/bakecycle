require "rails_helper"

describe Order do
  let(:order) { build(:order) }
  let(:today) { Date.today }
  let(:yesterday) { Date.today - 1.day }

  it "has model attributes" do
    expect(order).to respond_to(:client)
    expect(order).to respond_to(:route)
    expect(order).to respond_to(:start_date)
    expect(order).to respond_to(:end_date)
    expect(order).to respond_to(:note)
    expect(order).to respond_to(:order_items)
    expect(order).to respond_to(:order_type)
    expect(order).to belong_to(:bakery)
    expect(order).to belong_to(:client)
    expect(order).to belong_to(:route)
  end

  it "has validations" do
    expect(order).to validate_presence_of(:client)
    expect(order).to validate_presence_of(:route)
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

  describe ".temporary" do
    it "returns all temporary orders on a date" do
      temp_order = create(:temporary_order, start_date: today)
      create(:temporary_order, start_date: today + 1.day)
      create(:order)

      expect(Order.temporary(today)).to contain_exactly(temp_order)
    end
  end

  describe ".standing" do
    it "returns all standing orders active on a day" do
      order = create(:order, start_date: today, end_date: today)
      order2 = create(:order, start_date: yesterday, end_date: today + 1.day)
      order3 = create(:order, start_date: yesterday, end_date: nil)
      create(:order, start_date: yesterday, end_date: yesterday)
      create(:temporary_order, start_date: today)

      expect(Order.standing(today)).to contain_exactly(order, order2, order3)
    end
  end

  describe ".active" do
    it "returns all active orders for a client and date" do
      order = create(:order, start_date: yesterday)
      client = order.client
      temp_order = create(:temporary_order, start_date: today, client: client, route: order.route)
      different_route = create(:order, start_date: yesterday, client: client)

      expect(Order.active(client, yesterday)).to contain_exactly(order, different_route)
      expect(Order.active(client, today)).to contain_exactly(temp_order, different_route)
    end
  end
end
