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
  end

  it "has validations" do
    expect(order).to belong_to(:client)
    expect(order).to validate_presence_of(:client)
    expect(order).to belong_to(:route)
    expect(order).to validate_presence_of(:route)
    expect(order).to validate_presence_of(:start_date)
    expect(order).to validate_presence_of(:order_items)
  end
end
