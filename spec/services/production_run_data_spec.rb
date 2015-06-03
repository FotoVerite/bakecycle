require 'rails_helper'

describe ProductionRunData do
  describe '#add_nested_recipes' do
    let(:bakery) { create(:bakery) }
    let(:motherdough) {
      create(:recipe_motherdough, :with_nested_recipes, :with_ingredients,
             name: 'motherdough recipe', recipe_count: 1, bakery: bakery)
    }
    let(:product) { create(:product, motherdough: motherdough, weight: 100, unit: :g, bakery: bakery) }
    let(:run_item) { create(:run_item, order_quantity: 80, overbake_quantity: 20, product: product) }
    let(:production_run) { run_item.production_run }

    it 'collects all the relevant recipes' do
      data = ProductionRunData.new(production_run)
      expect(data.recipes.count).to eq(2)
    end
  end
end
