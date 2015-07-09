require 'rails_helper'

describe WeightDisplayer do
  let(:mock_class) { Class.new { include WeightDisplayer } }

  describe '.display_weight(weight)' do
    it 'shows weight in KG and color white when above weight is above 0.001 kg' do
      expect(mock_class.new.display_weight(100)).to eq(
        content: '100 kg',
        background_color: 'ffffff'
      )
    end

    it 'shows weight in KG and color white when above weight is  0 kg' do
      expect(mock_class.new.display_weight(0)).to eq(
        content: '0 kg',
        background_color: 'ffffff'
      )
    end

    it 'converts the weight to grams and fills in grey when weight is less than 0.001 kg' do
      expect(mock_class.new.display_weight(0.0001)).to eq(
        content: '0.1 g',
        background_color: 'd3d3d3'
      )
    end

    it 'rounds the weight' do
      expect(mock_class.new.display_weight(100.9382)).to eq(
        content: '100.938 kg',
        background_color: 'ffffff'
      )
    end
  end
end
