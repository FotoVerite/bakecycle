require 'rails_helper'

describe WeightDisplayer do
  let(:mock_class) { Class.new { include WeightDisplayer } }

  describe '.display_weight(weight)' do
    it 'shows weight in KG when above weight is above 1' do
      expect(mock_class.new.display_weight(100)).to eq '100 kg'
    end

    it 'converts the weight to grams when wheight is less than 1' do
      expect(mock_class.new.display_weight(0.01)).to eq '10 g'
    end

    it 'rounds the weight' do
      expect(mock_class.new.display_weight(100.9382)).to eq '100.938 kg'
    end
  end
end
