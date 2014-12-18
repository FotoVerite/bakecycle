require 'rails_helper'

describe RecipeItem do

  let(:recipe_item_ingredient) { build(:recipe_item_ingredient) }
  let(:recipe_item_recipe) { build(:recipe_item_recipe) }

  describe "Recipe Item Recipe" do

    describe "model attributes" do

      it { expect(recipe_item_recipe).to respond_to(:recipe) }
      it { expect(recipe_item_recipe).to respond_to(:inclusionable) }
      it { expect(recipe_item_recipe).to respond_to(:inclusionable_id) }
      it { expect(recipe_item_recipe).to respond_to(:inclusionable_type) }
      it { expect(recipe_item_recipe).to respond_to(:bakers_percentage) }
      it { expect(recipe_item_recipe).to belong_to(:recipe) }

    end

    describe "validations" do

      describe "bakers_percentage" do

        it { expect(recipe_item_recipe).to validate_numericality_of(:bakers_percentage) }
        it { expect(recipe_item_recipe).to validate_presence_of(:bakers_percentage) }

        it "is a number with 2 decimals" do
          expect(build(:recipe_item_recipe, bakers_percentage: 12.011)).to be_valid
        end

        it "is not a number" do
          expect(build(:recipe_item_recipe, bakers_percentage: "not a number")).to_not be_valid
        end

        it "has more than 3 decimals" do
          expect(build(:recipe_item_recipe, bakers_percentage: 0.1234)).to_not be_valid
        end

        it "has less than 3 decimals" do
          expect(build(:recipe_item_recipe, bakers_percentage: 0.1)).to be_valid
        end
      end

      describe "recipe_id" do
        it { expect(recipe_item_recipe).to validate_presence_of(:recipe) }
        it { expect(build(:recipe_item_recipe, recipe: nil)).to_not be_valid }
      end

      describe "inclusionable" do
        it { expect(recipe_item_recipe).to validate_presence_of(:inclusionable) }
        it { expect(build(:recipe_item_recipe, inclusionable: nil)).to_not be_valid }
        it { expect(build(:recipe_item_recipe, inclusionable_type: nil)).to_not be_valid }
        it { expect(build(:recipe_item_recipe, inclusionable_id: nil)).to_not be_valid }
      end
    end
  end
end
