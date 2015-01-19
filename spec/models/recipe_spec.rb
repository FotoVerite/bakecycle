require "rails_helper"

describe Recipe do
  let(:recipe) { build(:recipe) }

  describe "model attributes" do
    it { expect(recipe).to respond_to(:name) }
    it { expect(recipe).to respond_to(:note) }
    it { expect(recipe).to respond_to(:mix_size) }
    it { expect(recipe).to respond_to(:mix_size_unit) }
    it { expect(recipe).to respond_to(:recipe_type) }
    it { expect(recipe).to respond_to(:lead_days) }
  end

  describe "validations" do
    describe "name" do
      it { expect(recipe).to validate_presence_of(:name) }
      it { expect(recipe).to ensure_length_of(:name).is_at_most(150) }
      it { expect(recipe).to validate_uniqueness_of(:name) }
    end

    describe "mix_size" do
      it { expect(recipe).to validate_numericality_of(:mix_size) }

      it "is a number with 3 decimals" do
        expect(build(:recipe, mix_size: 12.011)).to be_valid
      end

      it "is not a number" do
        expect(build(:recipe, name: "this is our test", mix_size: "not a number")).to_not be_valid
      end

      it "has more than 3 decimals" do
        expect(build(:recipe, mix_size: 0.1234)).to_not be_valid
      end

      it "has less than 3 decimals" do
        expect(build(:recipe, mix_size: 0.12)).to be_valid
        expect(build(:recipe, mix_size: 0.1)).to be_valid
        expect(build(:recipe, mix_size: 1)).to be_valid
      end
    end

    describe "note" do
      it { expect(recipe).to ensure_length_of(:note).is_at_most(500) }
    end

    describe "lead_days" do
      it { expect(recipe).to validate_numericality_of(:lead_days) }
    end

    describe "mix_size_unit" do
      it { expect(recipe).to validate_presence_of(:mix_size_unit) }
      it { expect(build(:recipe, mix_size_unit: nil)).to_not be_valid }
      it { expect(build(:recipe, mix_size_unit: 0)).to be_valid }
    end

    describe "recipe_type" do
      it { expect(recipe).to validate_presence_of(:recipe_type) }
    end
  end
end
