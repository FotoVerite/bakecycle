require "rails_helper"

describe Ingredient do
  let(:ingredient) { FactoryGirl.build(:ingredient) }

  describe "model attributes" do
    it { expect(ingredient).to respond_to(:name) }
    it { expect(ingredient).to respond_to(:price) }
    it { expect(ingredient).to respond_to(:measure) }
    it { expect(ingredient).to respond_to(:unit) }
    it { expect(ingredient).to respond_to(:description) }
  end

  describe "validations" do

    describe "name" do
      it { expect(ingredient).to validate_presence_of(:name) }
      it { expect(ingredient).to ensure_length_of(:name).is_at_most(150) }
      it { expect(ingredient).to validate_uniqueness_of(:name) }
    end

    describe "price" do
      it { expect(ingredient).to validate_numericality_of(:price)}

      it "is a number with 2 decimals" do
        expect(build(:ingredient, price: 12.01)).to be_valid
      end

      it "is not a number" do
        expect(build(:ingredient, name: "this is our test", price: "not a number")).to_not be_valid
      end

      it "has a length no higher than 9" do
        expect(build(:ingredient, price: 123456.89)).to be_valid
      end

      it "has a length higher than 9" do
        expect(build(:ingredient, price: 12345678.90)).to_not be_valid
      end

      it "has more than 2 decimals" do
        expect(build(:ingredient, price: 0.123)).to_not be_valid
      end

      it "has less than 2 decimals" do
        expect(build(:ingredient, price: 0.1)).to be_valid
      end
    end

    describe "measure" do
      it { expect(ingredient).to validate_numericality_of(:measure)}

      it "is a number with 3 decimals" do
        expect(build(:ingredient, measure: 12.011)).to be_valid
      end

      it "is not a number" do
        expect(build(:ingredient, name: "this is our test", measure: "not a number")).to_not be_valid
      end

      it "has a length no higher than 9" do
        expect(build(:ingredient, measure: 123456.76)).to be_valid
      end

      it "has a length higher than 9" do
        expect(build(:ingredient, measure: 12345678.90)).to_not be_valid
      end

      it "has more than 3 decimals" do
        expect(build(:ingredient, measure: 0.1234)).to_not be_valid
      end

      it "has less than 3 decimals" do
        expect(build(:ingredient, measure: 0.12)).to be_valid
      end
    end

    describe "description" do
      it { expect(ingredient).to ensure_length_of(:description).is_at_most(500) }
    end
  end
end
