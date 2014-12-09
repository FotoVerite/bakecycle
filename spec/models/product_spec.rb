require "rails_helper"

describe Product do
  let(:product) { FactoryGirl.build(:product) }

  describe "model attributes" do
    it { expect(product).to respond_to(:name) }
    it { expect(product).to respond_to(:product_type) }
    it { expect(product).to respond_to(:description) }
    it { expect(product).to respond_to(:weight) }
    it { expect(product).to respond_to(:unit) }
    it { expect(product).to respond_to(:extra_amount) }
    it { expect(product).to respond_to(:motherdough) }
    it { expect(product).to respond_to(:inclusion) }
  end

  describe "validations" do

    describe "name" do
      it { expect(product).to validate_presence_of(:name) }
      it { expect(product).to validate_uniqueness_of(:name) }
    end

    describe "product_type" do
      it { expect(product).to validate_presence_of(:product_type) }
    end

    describe "description" do
      it { expect(product).to ensure_length_of(:description).is_at_most(500) }
    end

    describe "weight" do
      it { expect(product).to validate_numericality_of(:weight) }

      it "is a number with 3 decimals" do
        expect(build(:product, weight: 12.011)).to be_valid
      end

      it "is not a number" do
        expect(build(:product, name: "this is our test", weight: "not a number")).to_not be_valid
      end

      it "has more than 3 decimals" do
        expect(build(:product, weight: 0.1234)).to_not be_valid
      end

      it "has less than 3 decimals" do
        expect(build(:product, weight: 0.12)).to be_valid
        expect(build(:product, weight: 0.1)).to be_valid
        expect(build(:product, weight: 1)).to be_valid

      end
    end

    describe "unit" do
      it { expect(build(:product, unit: nil)).to be_valid }
      it { expect(build(:product, unit: 0)).to be_valid }
    end

    describe "extra_amount" do
      it { expect(product).to validate_numericality_of(:extra_amount) }

      it "is a number with 3 decimals" do
        expect(build(:product, extra_amount: 12.011)).to be_valid
      end

      it "is not a number" do
        expect(build(:product, name: "this is our test", extra_amount: "not a number")).to_not be_valid
      end

      it "has more than 3 decimals" do
        expect(build(:product, extra_amount: 0.1234)).to_not be_valid
      end

      it "has less than 3 decimals" do
        expect(build(:product, extra_amount: 0.12)).to be_valid
        expect(build(:product, extra_amount: 0.1)).to be_valid
        expect(build(:product, extra_amount: 1)).to be_valid
      end
    end

    describe "motherdough" do
      it "has a motherdough" do
        expect(build(:product)).to belong_to(:motherdough)
      end
    end

    describe "inclusion" do
      it "has a inclusion" do
        expect(build(:product)).to belong_to(:inclusion)
      end
    end

  end

end
