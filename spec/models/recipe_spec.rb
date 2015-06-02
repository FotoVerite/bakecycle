require 'rails_helper'

describe Recipe do
  let(:bakery) { build_stubbed(:bakery) }
  let(:recipe) { build_stubbed(:recipe, bakery: bakery) }
  let(:product) { build_stubbed(:product, motherdough: recipe) }

  it 'has model attributes' do
    expect(recipe).to respond_to(:name)
    expect(recipe).to respond_to(:note)
    expect(recipe).to respond_to(:mix_size)
    expect(recipe).to respond_to(:mix_size_unit)
    expect(recipe).to respond_to(:recipe_type)
    expect(recipe).to respond_to(:lead_days)
    expect(recipe).to respond_to(:products)
  end

  it 'has association' do
    expect(recipe).to belong_to(:bakery)
    expect(recipe).to have_many(:recipe_items)
    expect(recipe).to have_many(:parent_recipe_items)
    expect(recipe).to have_many(:parent_recipes)
    expect(recipe).to have_many(:child_recipes)
  end

  it 'has validations' do
    expect(recipe).to validate_presence_of(:recipe_type)
    expect(recipe).to validate_presence_of(:name)
    expect(recipe).to validate_length_of(:name).is_at_most(150)
    expect(recipe).to validate_length_of(:note).is_at_most(500)
    expect(recipe).to validate_numericality_of(:lead_days)
    expect(recipe).to validate_numericality_of(:mix_size)
  end

  describe 'unique tests' do
    it 'has validations that need the db' do
      recipe = build(:recipe, name: 'parent recipe')
      expect(recipe).to validate_uniqueness_of(:name).scoped_to(:bakery_id)
    end
  end

  describe '#total_lead_days' do
    let(:recipe) { create(:recipe_motherdough) }
    let(:bakery) { recipe.bakery }

    it 'calculated from own lead_days plus max of included recipe lead days, is called in an after save' do
      product
      dough = build(:recipe_motherdough, name: 'child recipe', bakery: bakery, lead_days: 4)
      recipe_item = build(:recipe_item_recipe, bakery: bakery, inclusionable: dough, recipe_lead_days: 2)
      recipe.recipe_items = [recipe_item]
      recipe.save
      recipe.reload

      expect(recipe.total_lead_days).to eq(6)
    end

    it 'works with stacked recipes' do
      dough = build(:recipe_motherdough, :with_nested_recipes, recipe_lead_days: 2, lead_days: 4, bakery: bakery)
      recipe_item = build(:recipe_item_recipe, bakery: bakery, inclusionable: dough, recipe_lead_days: 2)
      recipe.recipe_items = [recipe_item]
      expect(recipe.calculate_total_lead_days).to eq(8)

      recipe.save
      recipe.reload
      expect(recipe.total_lead_days).to eq(8)
    end
  end

  describe '#mix_size_unit' do
    it 'is required when there is a mix_size' do
      recipe = build(:recipe, mix_size: 1, mix_size_unit: :g)
      expect(recipe).to be_valid
      recipe.mix_size_unit = nil
      expect(recipe).to_not be_valid
    end

    it 'is not required when there is no mix size' do
      recipe = build(:recipe, mix_size: nil, mix_size_unit: nil)
      expect(recipe).to be_valid
    end
  end

  context 'make lead day zero if inclusion' do
    it 'makes recipe lead days zero if its type is inclusion' do
      recipe = create(:recipe, lead_days: 10, recipe_type: :inclusion)
      expect(recipe.lead_days).to eq(0)
    end
  end

  context 'make lead day one if preferment' do
    it 'makes recipe lead days one if its type is preferment' do
      recipe = create(:recipe, lead_days: 10, recipe_type: :preferment)
      expect(recipe.lead_days).to eq(1)
    end
  end

  describe 'inclusionable_a_recipe?' do
    it 'checks to see if recipe inclusionable is a recipe' do
      bakery = create(:bakery)
      dough = build(:recipe_preferment, bakery: bakery, lead_days: 4)
      recipe = build(:recipe, recipe_type: :inclusion)
      recipe_item = build(:recipe_item_recipe, bakery: bakery, inclusionable: dough)
      recipe.recipe_items = [recipe_item]
      expect(recipe).to_not be_valid
    end
  end
end
