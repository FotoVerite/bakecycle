require 'rails_helper'
require 'legacy_importer'

describe LegacyIngredientImporter do
  let(:bakery) { create(:bakery) }
  let(:connection) { instance_double(Mysql2::Client, query: [legacy_ingredient]) }
  let(:importer) { LegacyIngredientImporter.new(bakery: bakery, connection: connection) }

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
    it 'returns successful imports and unsuccessful imports' do
      invalid_ingredient = legacy_ingredient.dup.merge(ingredient_name: nil)
      expect(connection).to receive(:query).and_return([legacy_ingredient, invalid_ingredient])
      valid_ingredients, error_ingredients = importer.import!

      expect(error_ingredients.count).to eq(1)
      expect(valid_ingredients.count).to eq(1)
    end

    it 'creates a Client out of a LegacyClient' do
      (ingredient, _), _ = importer.import!
      expect(ingredient).to be_an_instance_of(Ingredient)
      # expect(ingredient.active).to eq(true)
      expect(ingredient).to be_valid
      expect(ingredient).to be_persisted
    end

    it 'updates existing clients' do
      (ingredient, _), _ = importer.import!
      legacy_ingredient[:ingredient_name] = 'New Name'
      (updated_ingredient, _), _ = importer.import!

      expect(updated_ingredient.name).to eq('New Name')
      expect(ingredient).to eq(updated_ingredient)
      ingredient.reload
      expect(ingredient.name).to eq('New Name')
    end
  end
end
