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

  it 'prevents infinite loops' do
    recipe = create(:recipe)
    item = RecipeItem.new(recipe_id: recipe.id, inclusionable: recipe, bakers_percentage: 1)
    expect(item).to_not be_valid

    item = RecipeItem.new(bakers_percentage: 1)
    expect(item).to_not be_valid

    item = RecipeItem.new(recipe_id: recipe.id, bakers_percentage: 1)
    expect(item).to_not be_valid
  end
end
