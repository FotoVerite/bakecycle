require 'rails_helper'
require 'legacy_importer'

describe LegacyImporter::IngredientImporter do
  let(:bakery) { create(:bakery) }
  let(:importer) { LegacyImporter::IngredientImporter.new(bakery, legacy_ingredient) }

  let(:legacy_ingredient) do
    HashWithIndifferentAccess.new(
      ingredient_id: 2,
      ingredient_name: 'Yeast, Instant Red Label SAF 20/1#',
      ingredient_cost: BigDecimal.new('0.5'),
      ingredient_measure: BigDecimal.new('0.2'),
      ingredient_unit: 'lb',
      ingredient_description: '',
      ingredient_type: 'ingredient',
      ingredient_active: 'Y'
    )
  end

  describe '#import!' do
    it 'creates a Ingredient out of a legacy_ingredient' do
      ingredient = importer.import!
      expect(ingredient).to be_an_instance_of(Ingredient)
      expect(ingredient).to be_valid
      expect(ingredient).to be_persisted
    end

    it 'returns unsuccessful import' do
      legacy_ingredient[:ingredient_name] = nil
      ingredient = importer.import!
      expect(ingredient).to_not be_valid
      expect(ingredient).to_not be_persisted
    end

    it 'updates existing clients' do
      ingredient = importer.import!
      legacy_ingredient[:ingredient_name] = 'New Name'
      updated_ingredient = importer.import!

      expect(updated_ingredient.name).to eq('New Name')
      expect(ingredient).to eq(updated_ingredient)
      ingredient.reload
      expect(ingredient.name).to eq('New Name')
    end
  end
end
