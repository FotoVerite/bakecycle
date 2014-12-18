require 'rails_helper'

describe ProductPrice do
  let(:product_price) { build(:product_price) }

  describe "Product Price" do
    describe "model attributes" do
      it { expect(product_price).to respond_to(:price) }
      it { expect(product_price).to respond_to(:quantity) }
      it { expect(product_price).to respond_to(:effective_date) }
      it { expect(product_price).to belong_to(:product) }
    end

    describe "validations" do
      describe "price" do
        it { expect(product_price).to validate_numericality_of(:price) }
        it { expect(product_price).to validate_presence_of(:price) }
        it "is a number with 2 decimals" do
          expect(build(:product_price, price: 12.01)).to be_valid
        end

        it "is not a number" do
          expect(build(:product_price, price: "not a number")).to_not be_valid
        end

        it "has more than 2 decimals" do
          expect(build(:product_price, price: 0.123)).to_not be_valid
        end

        it "has less than 2 decimals" do
          expect(build(:product_price, price: 0.1)).to be_valid
        end
      end

      describe "quantity" do
        it { expect(product_price).to validate_numericality_of(:quantity) }
        it { expect(product_price).to validate_presence_of(:quantity) }
      end

      describe "effective date" do
        it { expect(product_price).to validate_presence_of(:effective_date) }
      end
    end
  end
end
