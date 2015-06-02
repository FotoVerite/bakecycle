require 'rails_helper'

describe Ingredient do
  let(:ingredient) { build(:ingredient) }

  it 'has model attributes' do
    expect(ingredient).to respond_to(:name)
    expect(ingredient).to respond_to(:description)
  end

  it 'has association' do
    expect(ingredient).to belong_to(:bakery)
  end

  describe 'validations' do
    describe 'name' do
      it { expect(ingredient).to validate_presence_of(:name) }
      it { expect(ingredient).to validate_length_of(:name).is_at_most(150) }
      it { expect(ingredient).to validate_uniqueness_of(:name).scoped_to(:bakery_id) }

      it 'can have same name if are apart of different bakeries' do
        biencuit = create(:bakery)
        ingredient_name = 'Carrots'
        create(:ingredient, name: ingredient_name, bakery: biencuit)
        expect(create(:ingredient, name: ingredient_name)).to be_valid
      end
    end

    describe 'description' do
      it { expect(ingredient).to validate_length_of(:description).is_at_most(500) }
    end
  end
end
