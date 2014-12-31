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

  it "has validations" do
    expect(order).to belong_to(:client)
    expect(order).to validate_presence_of(:client)
    expect(order).to belong_to(:route)
    expect(order).to validate_presence_of(:route)
    expect(order).to validate_presence_of(:start_date)
    expect(order).to validate_presence_of(:order_items)
    expect(order).to validate_presence_of(:order_type)
  end

  describe "#set_end_date" do
    it "has a starting_date that ends on the same day" do
      temp_order = build(:temporary_order)
      temp_order.valid?
      expect(temp_order.start_date).to eq(temp_order.end_date)
    end
  end
end
