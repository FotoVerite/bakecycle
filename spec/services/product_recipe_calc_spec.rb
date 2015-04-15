require 'rails_helper'

describe ProductRecipeCalc do
  let(:product) { create(:product, :with_recipe_items) }
  let(:quantity) { 11 }
  let(:calculator) { ProductRecipeCalc.new(product, quantity) }
  let(:inclusion_percentage) { product.inclusion.recipe_items.map(&:bakers_percentage).sum }
  let(:dough_percentage) { product.motherdough.recipe_items.map(&:bakers_percentage).sum }
  let(:product_weight) { product.weight_with_unit.to_kg * quantity }
  let(:percent_weight) { product_weight / (dough_percentage + inclusion_percentage) }

  describe '.product_info' do
    it 'returns an object containing product, quantity and product weight' do
      product_info = {
        product: product,
        quantity: quantity,
        weight: product_weight
      }
      expect(calculator.product_info).to eq(product_info)
    end
  end

  describe '.inclusion_info' do
    it 'returns nil if product has no inclusion' do
      product.inclusion = nil
      expect(calculator.inclusion_info).to be_nil
    end

    it 'returns an object containing recipe inclusion and weight' do
      inclusion_weight = inclusion_percentage * percent_weight

      inclusion_info = {
        recipe: product.inclusion,
        weight: inclusion_weight
      }
      expect(calculator.inclusion_info).to eq(inclusion_info)
    end
  end

  describe '.dough_weight' do
    it 'returns a recipes dough weight' do
      dough_weight = dough_percentage * percent_weight
      expect(calculator.dough_weight).to eq(dough_weight)
    end
  end
end
