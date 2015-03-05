require 'rails_helper'

describe OrderItem do
  let(:order_item) { build(:order_item) }

  it 'has model attributes' do
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

  it 'has days of week default to 0' do
    order_item = build(:order_item, monday: nil)
    expect(order_item.monday).to eq(nil)
    order_item.save
    expect(order_item.monday).to eq(0)
  end

  it 'has association' do
    expect(order_item).to belong_to(:order)
    expect(order_item).to belong_to(:product)
  end

  it 'has validations' do
    expect(order_item).to validate_numericality_of(:monday)
    expect(order_item).to validate_numericality_of(:tuesday)
    expect(order_item).to validate_numericality_of(:wednesday)
    expect(order_item).to validate_numericality_of(:thursday)
    expect(order_item).to validate_numericality_of(:friday)
    expect(order_item).to validate_numericality_of(:saturday)
    expect(order_item).to validate_numericality_of(:sunday)
  end

  describe '#total_quantity' do
    it 'sums up the quantity of each day' do
      order_item = build(
        :order_item,
        monday: 1,
        tuesday: 2,
        wednesday: 10,
        thursday: 0,
        friday: 0,
        saturday: 0,
        sunday: nil
      )
      expect(order_item.total_quantity).to eq(13)
    end
  end

  describe '#lead_time' do
    it 'returns max lead time for the order_item' do
      motherdough = create(:recipe_motherdough, lead_days: 5)
      inclusion = create(:recipe_inclusion, lead_days: 3)
      product = create(:product, inclusion: inclusion, motherdough: motherdough)
      order = create(:order)
      order_item = create(:order_item, order: order, product: product)

      expect(order_item.lead_time).to eq(5)
    end
  end

  describe '#quantity' do
    it 'returns the quantity ordered on a date' do
      order_item = OrderItem.new(monday: 4)
      monday = Date.parse('16/02/2015')
      expect(order_item.quantity(monday)).to eq(order_item.monday)
    end
  end

  context '#total_quantity_price' do
    it 'calculates total quantity price for an order item' do
      apple = create(:product, name: 'Apple', base_price: 0.5)
      create(:price_varient, product: apple, quantity: 11, price: 0.4)
      create(:price_varient, product: apple, quantity: 13, price: 0.2)
      create(:price_varient, product: apple, quantity: 15, price: 0.1)

      order_item = create(
        :order_item,
        product: apple,
        monday: 1,
        tuesday: 1,
        wednesday: 1,
        thursday: 1,
        friday: 1,
        saturday: 1,
        sunday: 1
      )

      expect(order_item.total_quantity_price).to eq(3.5)

      order_item.monday = 4
      expect(order_item.total_quantity_price).to eq(5)

      order_item.monday = 11
      expect(order_item.total_quantity_price).to eq(1.7)
    end
  end
end
