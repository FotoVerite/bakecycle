require 'rails_helper'
require 'legacy_importer'

describe LegacyImporter::FieldMapper do
  let(:mapper) { LegacyImporter::FieldMapper.new(fields_map) }

  let(:fields_map) do
    %w(
      product_name          name
      product_shortname     sku
      product_description   description
      product_weight_g      weight
      product_extra         over_bake
      product_type          product_type
    )
  end

  describe '.translate' do
    it 'returns an empty hash for empty hash' do
      expect(mapper.translate({})).to eq({})
    end

    it 'copies and changes keys only for known fields' do
      legacy = {
        product_name: 'Apples',
        product_shortname: '11215',
        unknown_attr: 4
      }
      translated = {
        name: 'Apples',
        sku: '11215'
      }
      expect(mapper.translate(legacy)).to eq(translated)
    end
  end
end
