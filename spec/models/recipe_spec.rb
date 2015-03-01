require 'rails_helper'

describe Recipe do
  let(:recipe) { build(:recipe) }

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
    it 'has a name' do
      expect(recipe).to validate_presence_of(:name)
      expect(recipe).to ensure_length_of(:name).is_at_most(150)
      expect(recipe).to validate_uniqueness_of(:name).scoped_to(:bakery_id)
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

    describe 'note' do
      it { expect(recipe).to ensure_length_of(:note).is_at_most(500) }
    end

    describe 'lead_days' do
      it { expect(recipe).to validate_numericality_of(:lead_days) }
    end

    describe 'mix_size_unit' do
      it { expect(recipe).to validate_presence_of(:mix_size_unit) }
      it { expect(build(:recipe, mix_size_unit: nil)).to_not be_valid }
      it { expect(build(:recipe, mix_size_unit: 0)).to be_valid }
    end

    describe 'recipe_type' do
      it { expect(recipe).to validate_presence_of(:recipe_type) }
    end
  end
end
