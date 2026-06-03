require "rails_helper"

describe RecipeSerializer do
  let(:bakery) { create(:bakery) }
  let(:recipe) { create(:recipe, bakery: bakery) }

  before do
    allow_any_instance_of(RecipeDecorator).to receive(:ingredients).and_return([])
    allow_any_instance_of(RecipeDecorator).to receive(:recipes).and_return([])
  end

  # RecipeDecorator#serializable_hash calls RecipeSerializer.new(object).as_json
  # and then applies camelCase transform — test through the decorator to match production path.
  subject(:hash) { RecipeDecorator.new(recipe).serializable_hash }

  it "serializes without error" do
    expect { hash }.not_to raise_error
  end

  it "includes expected recipe attributes as camelCase string keys" do
    expect(hash).to include(
      "id" => recipe.id,
      "name" => recipe.name,
    )
  end

  it "includes recipeItems array under camelCase key" do
    expect(hash).to have_key("recipeItems")
    expect(hash["recipeItems"]).to be_an(Array)
  end

  it "includes form selection helpers under camelCase keys" do
    expect(hash).to have_key("availableInclusions")
    expect(hash).to have_key("availableRecipeIngredients")
    expect(hash).to have_key("recipeTypes")
    expect(hash).to have_key("mixUnits")
  end
end
