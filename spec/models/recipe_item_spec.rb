require 'rails_helper'

describe RecipeItem do
  let(:recipe_item_ingredient) { build(:recipe_item_ingredient) }
  let(:recipe_item_recipe) { build(:recipe_item_recipe) }

  it 'has model attributes' do
    expect(recipe_item_recipe).to respond_to(:inclusionable)
    expect(recipe_item_recipe).to respond_to(:inclusionable_id)
    expect(recipe_item_recipe).to respond_to(:inclusionable_type)
    expect(recipe_item_recipe).to respond_to(:bakers_percentage)
  end

  it 'has validations' do
    expect(recipe_item_recipe).to validate_numericality_of(:bakers_percentage)
    expect(recipe_item_recipe).to validate_presence_of(:bakers_percentage)
  end

  describe 'bakers_percentage' do
    it 'is a number with 2 decimals' do
      expect(build(:recipe_item_recipe, bakers_percentage: 12.011)).to be_valid
    end
    it 'is not a number' do
      expect(build(:recipe_item_recipe, bakers_percentage: 'not a number')).to_not be_valid
    end

    it 'has more than 3 decimals' do
      expect(build(:recipe_item_recipe, bakers_percentage: 0.1234)).to_not be_valid
    end

    it 'has less than 3 decimals' do
      expect(build(:recipe_item_recipe, bakers_percentage: 0.1)).to be_valid
    end
  end
end
