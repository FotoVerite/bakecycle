require "rails_helper"

describe Ingredient do
  let(:ingredient) { build(:ingredient) }

  describe "model attributes" do
    it { expect(ingredient).to respond_to(:name) }
    it { expect(ingredient).to respond_to(:price) }
    it { expect(ingredient).to respond_to(:measure) }
    it { expect(ingredient).to respond_to(:unit) }
    it { expect(ingredient).to respond_to(:ingredient_type) }
    it { expect(ingredient).to respond_to(:description) }
  end

  it "has association" do
    expect(ingredient).to belong_to(:bakery)
  end

  describe "validations" do
    describe "name" do
      it { expect(ingredient).to validate_presence_of(:name) }
      it { expect(ingredient).to ensure_length_of(:name).is_at_most(150) }
      it { expect(ingredient).to validate_uniqueness_of(:name) }
    end

    describe "price" do
      it { expect(ingredient).to validate_numericality_of(:price) }

      it "is a number with 2 decimals" do
        expect(build(:ingredient, price: 12.01)).to be_valid
      end

      it "is not a number" do
        expect(build(:ingredient, name: "this is our test", price: "not a number")).to_not be_valid
      end

      it "has more than 2 decimals" do
        expect(build(:ingredient, price: 0.123)).to_not be_valid
      end

      it "has less than 2 decimals" do
        expect(build(:ingredient, price: 0.1)).to be_valid
      end
    end

    describe "measure" do
      it { expect(ingredient).to validate_numericality_of(:measure) }

      it "is a number with 3 decimals" do
        expect(build(:ingredient, measure: 12.011)).to be_valid
      end

      it "is not a number" do
        expect(build(:ingredient, name: "this is our test", measure: "not a number")).to_not be_valid
      end

      it "has more than 3 decimals" do
        expect(build(:ingredient, measure: 0.1234)).to_not be_valid
      end

      it "has less than 3 decimals" do
        expect(build(:ingredient, measure: 0.12)).to be_valid
        expect(build(:ingredient, measure: 0.1)).to be_valid
        expect(build(:ingredient, measure: 1)).to be_valid
      end
    end

    describe "ingredient_type" do
      it { expect(ingredient).to validate_presence_of(:ingredient_type) }
      it { expect(build(:ingredient, ingredient_type: nil)).to_not be_valid }
      it { expect(build(:ingredient, ingredient_type: 0)).to be_valid }
    end

    describe "description" do
      it { expect(ingredient).to ensure_length_of(:description).is_at_most(500) }
    end

    describe "unit" do
      it { expect(ingredient).to validate_presence_of(:unit) }
      it { expect(build(:ingredient, unit: nil)).to_not be_valid }
      it { expect(build(:ingredient, unit: 0)).to be_valid }
    end
  end
end
