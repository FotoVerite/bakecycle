require 'rails_helper'

describe Recipe do
  let(:recipe) { build_stubbed(:recipe) }
  let(:bakery) { recipe.bakery }

  it 'has model attributes' do
    expect(recipe).to respond_to(:name)
    expect(recipe).to respond_to(:note)
    expect(recipe).to respond_to(:mix_size)
    expect(recipe).to respond_to(:mix_size_unit)
    expect(recipe).to respond_to(:recipe_type)
    expect(recipe).to respond_to(:lead_days)
  end

  it 'has association' do
    expect(recipe).to belong_to(:bakery)
  end

  describe 'validations' do
    it 'has validations' do
      recipe = build(:recipe)
      expect(recipe).to validate_presence_of(:recipe_type)
      expect(recipe).to validate_presence_of(:name)
      expect(recipe).to ensure_length_of(:name).is_at_most(150)
      expect(recipe).to validate_uniqueness_of(:name).scoped_to(:bakery_id)
      expect(recipe).to ensure_length_of(:note).is_at_most(500)
      expect(recipe).to validate_numericality_of(:lead_days)
    end

    it 'can have same name if are apart of different bakeries' do
      biencuit = create(:bakery)
      recipe_name = 'Carrot Baguette'
      create(:recipe, name: recipe_name, bakery: biencuit)
      expect(create(:recipe, name: recipe_name)).to be_valid
    end

    describe 'mix_size' do
      it { expect(recipe).to validate_numericality_of(:mix_size) }

      it 'is a number with 3 decimals' do
        expect(build(:recipe, mix_size: 12.011)).to be_valid
      end

      it 'is not a number' do
        expect(build(:recipe, name: 'this is our test', mix_size: 'not a number')).to_not be_valid
      end

      it 'has more than 3 decimals' do
        expect(build(:recipe, mix_size: 0.1234)).to_not be_valid
      end

      it 'has less than 3 decimals' do
        expect(build(:recipe, mix_size: 0.12)).to be_valid
        expect(build(:recipe, mix_size: 0.1)).to be_valid
        expect(build(:recipe, mix_size: 1)).to be_valid
      end
    end
  end

  describe 'total_lead_days' do
    let(:recipe) { create(:recipe) }
    let(:bakery) { recipe.bakery }

    it 'checks the lead time of all included recipes, and adds the longest to its own total_lead_days' do
      dough = build(:recipe_preferment, bakery: bakery, lead_days: 4)
      recipe_item = build(:recipe_item_recipe, bakery: bakery, inclusionable: dough, recipe_lead_days: 2)
      recipe.recipe_items = [recipe_item]

      expect(recipe.total_lead_days).to eq(6)
    end

    it 'works with stacked recipes' do
      dough = build(:recipe_preferment, :with_nested_recipe, recipe_lead_days: 2, lead_days: 4, bakery: bakery)
      recipe_item = build(:recipe_item_recipe, bakery: bakery, inclusionable: dough, recipe_lead_days: 2)
      recipe.recipe_items = [recipe_item]
      expect(recipe.total_lead_days).to eq(8)
    end
  end

  describe 'mix_size_unit' do
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

  describe 'make_lead_day_zero_if_inclusion' do
    it 'makes recipe lead days zero if its type is inclusion' do
      recipe = create(:recipe, lead_days: 10, recipe_type: :inclusion)
      expect(recipe.lead_days).to eq(0)
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
