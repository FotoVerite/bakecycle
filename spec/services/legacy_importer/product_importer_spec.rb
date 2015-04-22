require 'rails_helper'
require 'legacy_importer'

describe LegacyImporter::ProductImporter do
  let(:bakery) { create(:bakery) }
  let(:importer) { LegacyImporter::ProductImporter.new(bakery, legacy_product) }
  let(:legacy_product) do
    HashWithIndifferentAccess.new(
      'product_name' => 'Olive Campagne Loaf',
      'product_shortname' => 'olivecampagne',
      'product_description' => 'Olive and such',
      'product_weight_g' => 1200.0,
      'product_extra' => 0.0,
      'product_type' => :bread,
      'product_recipeid' => 10000,
      'product_inclusionid' => 10001,
      'base_price' => '',
      'product_active' => 'Y'
    )
  end

  describe '#import!' do
    it 'creates a Product out of a LegacyProduct' do
      create(:recipe_motherdough, legacy_id: 10000)
      create(:recipe_inclusion, legacy_id: 10001)
      product = importer.import!
      expect(product).to be_an_instance_of(Product)
      expect(product).to be_valid
      expect(product).to be_persisted
    end

    it 'has the correct motherdough and inclusion' do
      recipe_motherdough = create(:recipe_motherdough, legacy_id: 10000)
      recipe_inclusion = create(:recipe_inclusion, legacy_id: 10001)
      product = importer.import!
      expect(product.inclusion).to eq(recipe_inclusion)
      expect(product.motherdough).to eq(recipe_motherdough)
    end
  end
end
