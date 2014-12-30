require 'rails_helper'

describe PriceVarient do
  let(:price_varient) { build(:price_varient) }

  it "has model attributes" do
    expect(price_varient).to respond_to(:price)
    expect(price_varient).to respond_to(:quantity)
    expect(price_varient).to respond_to(:effective_date)
    expect(price_varient).to belong_to(:product)
  end

  describe "validations" do
    it "has a price and it is a number" do
      expect(price_varient).to validate_numericality_of(:price)
      expect(price_varient).to validate_presence_of(:price)
      expect(build(:price_varient, price: 12.01)).to be_valid
      expect(build(:price_varient, price: "not a number")).to_not be_valid
      expect(build(:price_varient, price: 0.123)).to_not be_valid
      expect(build(:price_varient, price: 0.1)).to be_valid
    end

    it "has a quantity and it is a number" do
      expect(price_varient).to validate_numericality_of(:quantity)
      expect(price_varient).to validate_presence_of(:quantity)
    end

    it "has an effective date" do
      expect(price_varient).to validate_presence_of(:effective_date)
    end
  end
end
