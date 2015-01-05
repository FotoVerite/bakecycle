require "rails_helper"

describe Product do
  let(:product) { build(:product) }

  it "has model attributes" do
    expect(product).to respond_to(:name)
    expect(product).to respond_to(:product_type)
    expect(product).to respond_to(:description)
    expect(product).to respond_to(:weight)
    expect(product).to respond_to(:unit)
    expect(product).to respond_to(:extra_amount)
    expect(product).to respond_to(:motherdough)
    expect(product).to respond_to(:inclusion)
    expect(product).to respond_to(:base_price)
  end

  describe "validations" do

    it "has a name" do
      expect(product).to validate_presence_of(:name)
      expect(product).to validate_uniqueness_of(:name)
    end

    it "has a product type" do
      expect(product).to validate_presence_of(:product_type)
    end

    it "has a base price" do
      expect(product).to validate_presence_of(:base_price)
      expect(product).to validate_numericality_of(:base_price)
      expect(build(:product, base_price: 12.011)).to_not be_valid
      expect(build(:product, base_price: 12.01)).to be_valid
    end

    it "has a description" do
      expect(product).to ensure_length_of(:description).is_at_most(500)
    end

    it "has a weight that is a number" do
      expect(product).to validate_numericality_of(:weight)
      expect(build(:product, weight: 12.011)).to be_valid
      expect(build(:product, name: "this is our test", weight: "not a number")).to_not be_valid
      expect(build(:product, weight: 0.1234)).to_not be_valid
      expect(build(:product, weight: 0.12)).to be_valid
      expect(build(:product, weight: 0.1)).to be_valid
      expect(build(:product, weight: 1)).to be_valid
    end

    it "has a unit" do
      expect(build(:product, unit: nil)).to be_valid
      expect(build(:product, unit: 0)).to be_valid
    end

    it "has an extra_amount that is a number" do
      expect(product).to validate_numericality_of(:extra_amount)
      expect(build(:product, extra_amount: 12.011)).to be_valid
      expect(build(:product, name: "this is our test", extra_amount: "not a number")).to_not be_valid
      expect(build(:product, extra_amount: 0.1234)).to_not be_valid
      expect(build(:product, extra_amount: 0.12)).to be_valid
      expect(build(:product, extra_amount: 0.1)).to be_valid
      expect(build(:product, extra_amount: 1)).to be_valid
    end

    it "has a motherdough" do
      expect(build(:product)).to belong_to(:motherdough)
    end

    it "has a inclusion" do
      expect(build(:product)).to belong_to(:inclusion)
    end
  end
  context 'when calculating weekly price' do
    before do
      @apple = FactoryGirl.create(:product, name: "Apple", base_price: 0.5)
      @price_1 = FactoryGirl.create(
        :price_varient, product: @apple, quantity: 11, effective_date: "2015-01-01", price: 0.4)
      @price_2 = FactoryGirl.create(
        :price_varient, product: @apple, quantity: 10, effective_date: "2015-01-07", price: 0.2)
      @price_3 = FactoryGirl.create(
        :price_varient, product: @apple, quantity: 12, effective_date: "2015-01-05", price: 0.3)
      @price_4 = FactoryGirl.create(
        :price_varient, product: @apple, quantity: 13, effective_date: "2015-01-07", price: 0.25)
      @price_5 = FactoryGirl.create(
        :price_varient, product: @apple, quantity: 14, effective_date: "2015-01-10", price: 0.1)
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

    it "calculates weekly price for an order item" do
      quantity = @order_item.weekly_quantity
      expect(@order_item.product.weekly_price(quantity)).to eq(3.5)

      quantity = 10
      expect(@order_item.product.weekly_price(quantity)).to eq(2.0)

      quantity = 20
      expect(@order_item.product.weekly_price(quantity)).to eq(5)
    end
  end
end
