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
        sunday: nil
      )
    end

    it "calculates weekly total quantity for an order_item" do
      expect(order_item.weekly_quantity).to eq(13)
    end
  end
  context 'when calculating weekly price' do
    before do
      @apple = FactoryGirl.create(:product, name: "Apple", base_price: 0.5)
      @price_1 = FactoryGirl.create(
        :price_varient, product: @apple, quantity: 11, effective_date: (Date.today - 6), price: 0.4)
      @price_2 = FactoryGirl.create(
        :price_varient, product: @apple, quantity: 10, effective_date: Date.today, price: 0.2)
      @price_3 = FactoryGirl.create(
        :price_varient, product: @apple, quantity: 12, effective_date: (Date.today - 2), price: 0.3)
      @price_4 = FactoryGirl.create(
        :price_varient, product: @apple, quantity: 13, effective_date: Date.today, price: 0.25)
      @price_5 = FactoryGirl.create(
        :price_varient, product: @apple, quantity: 14, effective_date: (Date.today + 3), price: 0.1)
      @order_item = FactoryGirl.create(
            :order_item,
            product: @apple,
            monday: 1,
            tuesday: 1,
            wednesday: 1,
            thursday: 1,
            friday: 1,
            saturday: 1,
            sunday: 1)
    end

    it "calculates total quantity price for an order item" do
      expect(@order_item.total_quantity_price).to eq(3.5)

      @order_item.monday = 4
      expect(@order_item.total_quantity_price).to eq(2.0)

      @order_item.tuesday = 11
      expect(@order_item.total_quantity_price).to eq(5)
    end
  end

  describe "#lead_time" do
    it "returns max lead time for the order_item" do
      motherdough = create(:recipe_motherdough, lead_days: 5)
      inclusion = create(:recipe_inclusion, lead_days: 3)
      product = create(:product, inclusion: inclusion, motherdough: motherdough)
      order = create(:order)
      order_item = create(:order_item, order: order, product: product)

      expect(order_item.lead_time).to eq(5)
    end
  end
end
