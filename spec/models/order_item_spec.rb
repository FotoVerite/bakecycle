require 'rails_helper'

describe OrderItem do
  let(:order_item) { build(:order_item) }

  it "has model attributes" do
    expect(order_item).to respond_to(:product)
    expect(order_item).to respond_to(:order)
    expect(order_item).to respond_to(:monday)
    expect(order_item).to respond_to(:tuesday)
    expect(order_item).to respond_to(:wednesday)
    expect(order_item).to respond_to(:thursday)
    expect(order_item).to respond_to(:friday)
    expect(order_item).to respond_to(:saturday)
    expect(order_item).to respond_to(:sunday)
  end

  it "has days of week default to 0" do
    order_item = build(:order_item, monday: nil)
    expect(order_item.monday).to eq(nil)
    order_item.save
    expect(order_item.monday).to eq(0)
  end

  it "has association" do
    expect(order_item).to belong_to(:order)
    expect(order_item).to belong_to(:product)
  end

  it "has validations" do
    expect(order_item).to validate_numericality_of(:monday)
    expect(order_item).to validate_numericality_of(:tuesday)
    expect(order_item).to validate_numericality_of(:wednesday)
    expect(order_item).to validate_numericality_of(:thursday)
    expect(order_item).to validate_numericality_of(:friday)
    expect(order_item).to validate_numericality_of(:saturday)
    expect(order_item).to validate_numericality_of(:sunday)
  end

  context 'when calculating weekly price' do
    let(:order_item) do
      build(
        :order_item,
        monday: 1,
        tuesday: 2,
        wednesday: 10,
        thursday: 0,
        friday: 0,
        saturday: 0,
        sunday: 0
      )
    end

    it "calculates weekly total quantity for an order_item" do
      expect(order_item.weekly_quantity).to eq(13)
    end
  end
end
