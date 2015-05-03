require 'rails_helper'
require 'legacy_importer'

describe LegacyImporter::RecipeImporter do
  let(:bakery) { create(:bakery) }
  let(:importer) { LegacyImporter::RecipeImporter.new(bakery, legacy_recipe) }

  let(:legacy_recipe) do
    {
      recipe_id: 10000,
      recipe_name: 'Baguette',
      recipe_instructions: '',
      recipe_daystomake: 2,
      recipe_extra: BigDecimal.new('0'),
      recipe_type: 'motherdough',
      recipe_active: 'Y',
      recipe_print: 'Y',
      recipe_mix_size: 80
    }
  end

  describe '#import!' do
    it 'creates a recipe out of a legacy_recipe' do
      recipe = importer.import!
      expect(recipe).to be_an_instance_of(Recipe)
      expect(recipe).to be_valid
      expect(recipe).to be_persisted
    end

    it 'returns unsuccessful import' do
      legacy_recipe[:recipe_name] = nil
      recipe = importer.import!
      expect(recipe).to_not be_valid
      expect(recipe).to_not be_persisted
    end

    it 'updates existing recipes' do
      recipe = importer.import!
      legacy_recipe[:recipe_name] = 'New Name'
      updated_recipe = importer.import!

      expect(updated_recipe.name).to eq('New Name')
      expect(recipe).to eql(updated_recipe)
      recipe.reload
      expect(recipe.name).to eq('New Name')
    end
  end
end
