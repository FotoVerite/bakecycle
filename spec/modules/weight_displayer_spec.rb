require "rails_helper"

describe WeightDisplayer do
  let(:mock_class) { Class.new { include WeightDisplayer } }

  describe ".display_weight(weight)" do
    it "shows weight in G and color white by default" do
      expect(mock_class.new.display_weight(100, false)).to eq(
        content: "100000.000 g",
        background_color: "ffffff"
      )
    end

    it "shows weight in KG and color white when above weight is above 0.001 kg" do
      expect(mock_class.new.display_weight(100, true)).to eq(
        content: "100.000 kg",
        background_color: "ffffff"
      )
    end

    it "shows weight in KG and color white when above weight is  0 kg" do
      expect(mock_class.new.display_weight(0, true)).to eq(
        content: "0.000 kg",
        background_color: "ffffff"
      )
    end

    it "converts the weight to grams and fills in grey when weight is less than 0.001 kg" do
      expect(mock_class.new.display_weight(0.0001, true)).to eq(
        content: "0.100 g",
        background_color: "d3d3d3"
      )
    end

    it "rounds the weight" do
      expect(mock_class.new.display_weight(100.9382, true)).to eq(
        content: "100.938 kg",
        background_color: "ffffff"
      )
    end
  end
end
