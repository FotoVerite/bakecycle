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
      expect(data.recipes_collection.count).to eq(2)
    end
  end

  describe '#set_preferment_bowls' do
    it 'sets preferment bowl counts that are in one mother dough' do
      parent_recipes_array = [instance_double('RecipeRunData')]
      preferment_recipe_data = mock_recipe_run_preferment(parent_recipes_array)

      allow_any_instance_of(ProductionRunData).to receive(:preferments).and_return([preferment_recipe_data])
      allow_any_instance_of(RecipeCollection).to receive(:detect).and_return(mock_parent_recipe)
      expect(preferment_recipe_data).to receive(:mix_bowl_count=).with(3)
      ProductionRunData.new(ProductionRun.new)
    end

    it 'does not set preferment bowl counts that are in more than one mother dough' do
      parent_recipes_array = [instance_double('RecipeRunData'), instance_double('RecipeRunData')]
      preferment_recipe_data = mock_recipe_run_preferment(parent_recipes_array)

      allow_any_instance_of(ProductionRunData).to receive(:preferments).and_return([preferment_recipe_data])
      allow_any_instance_of(RecipeCollection).to receive(:detect).and_return(mock_parent_recipe)
      expect(preferment_recipe_data).not_to receive(:mix_bowl_count=)
      ProductionRunData.new(ProductionRun.new)
    end
  end

  def mock_recipe_run_preferment(parent_recipes_array)
    instance_double('RecipeRunData',
      mix_bowl_count: 1,
      parent_recipes: parent_recipes_array
                   )
  end

  def mock_parent_recipe
    instance_double('RecipeRunData',
      mix_bowl_count: 3,
      parent_recipes: []
                   )
  end
end
