require 'rails_helper'

describe RecipeRunData do
  describe '#add_product' do
    let(:motherdough) { create(:recipe_motherdough) }
    let(:inclusion) { create(:recipe_inclusion) }
    let(:product) { create(:product, motherdough: motherdough, weight: 1, unit: :g) }
    let(:run_data) { RecipeRunData.new(motherdough, date: Time.zone.today) }

    it 'keeps a list of products and their info' do
      allow_any_instance_of(ProductRecipeCalc).to receive(:dough_percentage).and_return(0)
      product_info = {
        product: product,
        quantity: 1,
        weight: Unitwise(1, :g),
        dough_weight: Unitwise(0, :kg)
      }
      run_data.add_product(product, 1)
      expect(run_data.products).to include(product_info)
    end

    it 'keeps a list of inclusions and their info' do
      product.inclusion = inclusion
      inclusion_info = {
        product: product,
        recipe: inclusion,
        inclusion_weight: Unitwise(0, :kg),
        dough_weight: Unitwise(0, :kg),
        product_weight: Unitwise(0.001, :kg)
      }
      run_data.add_product(product, 1)
      expect(run_data.inclusions).to include(inclusion_info)
    end

    it 'ignores inclusions with products that don\'t have them' do
      run_data.add_product(product, 1)
      expect(run_data.inclusions).to be_empty
    end

    it 'keeps a running total of recipe weight' do
      allow_any_instance_of(ProductRecipeCalc).to receive(:dough_weight).and_return(Unitwise(1, :kg))
      run_data.add_product(product, 1)
      expect(run_data.weight).to eq(Unitwise(1, :kg))
      run_data.add_product(product, 1)
      expect(run_data.weight).to eq(Unitwise(2, :kg))
    end

    describe 'ingredients and included recipes' do
      let(:motherdough) { create(:recipe, :with_ingredients, ingredient_count: 1) }
      it 'calculates the weights of recipe items' do
        recipe_item = motherdough.recipe_items.first
        recipe_item_info = {
          inclusionable: recipe_item.inclusionable,
          bakers_percentage: recipe_item.bakers_percentage,
          weight: Unitwise(1, :kg)
        }
        allow_any_instance_of(RecipeCalc).to receive(:ingredients_info).and_return([recipe_item_info])
        expect(run_data.recipe_items).to include(recipe_item_info)
      end

      it 'updates the weights of recipe items when the recipe weight changes' do
        run_data
        expect(RecipeCalc).to receive(:new).with(motherdough, Unitwise(5, :kg)).and_call_original
        run_data.weight = Unitwise(5, :kg)
        expect(RecipeCalc).to receive(:new).with(motherdough, Unitwise(6, :kg)).and_call_original
        run_data.weight = Unitwise(6, :kg)
      end

      it 'updates the weights of recipe items when you add products' do
        run_data
        expect(RecipeCalc).to receive(:new).and_call_original
        run_data.add_product(product, 1)
      end
    end

    describe '#ingredients and #nested_recipes' do
      let(:motherdough) { create(:recipe_motherdough, :with_nested_recipes, :with_ingredients) }

      it 'returns the ingredients from recipe items' do
        expect(run_data.ingredients.count).to eq(3)
        expect(run_data.ingredients.first[:inclusionable]).to be_a(Ingredient)
      end

      it 'returns the recipes from recipe items' do
        expect(run_data.nested_recipes.count).to eq(3)
        expect(run_data.nested_recipes.first[:inclusionable]).to be_a(Recipe)
      end
    end

    describe '#mix_bowl_count' do
      it 'returns nil if no bowl info' do
        motherdough.update(mix_size: 0)
        expect(run_data.mix_bowl_count).to eq(1)
        motherdough.update(mix_size: nil)
        expect(run_data.mix_bowl_count).to eq(1)
      end

      it 'returns the number of bowls needed' do
        motherdough.update(mix_size: 100, mix_size_unit: :g)
        run_data.weight = Unitwise(1, :kg)
        expect(run_data.mix_bowl_count).to eq(10)
        run_data.weight = Unitwise(101, :g)
        expect(run_data.mix_bowl_count).to eq(2)
      end
    end
  end

  describe '#update_parent_recipe' do
    let(:bakery) { create(:bakery) }
    let(:recipe) { create(:recipe, bakery: bakery) }
    let(:parent_recipe) { create(:recipe, bakery: bakery) }
    let(:parent_recipe_2) { create(:recipe, bakery: bakery) }
    let(:date) { Time.zone.now }
    let(:run_data) { RecipeRunData.new(recipe, date) }

    it 'it keeps a sum of the weight by recipe' do
      run_data.update_parent_recipe(parent_recipe, Unitwise(10, :kg))
      run_data.update_parent_recipe(parent_recipe, Unitwise(5, :kg))

      recipe_info = {
        parent_recipe: parent_recipe,
        weight: Unitwise(5, :kg)
      }
      expect(run_data.parent_recipes).to include(recipe_info)
      expect(run_data.weight).to eq(Unitwise(5, :kg))

      run_data.update_parent_recipe(parent_recipe_2, Unitwise(8, :kg))
      expect(run_data.parent_recipes).to include(recipe_info)
      expect(run_data.weight).to eq(Unitwise(13, :kg))
    end
  end

  describe '#add_recipe_inclusions_info' do
    let(:motherdough) { create(:recipe_motherdough) }
    let(:inclusion) { create(:recipe_inclusion, :with_ingredients) }
    let(:product) { create(:product, motherdough: motherdough, weight: 10, unit: :g) }
    let(:product2) { create(:product, motherdough: motherdough, weight: 10, unit: :g) }
    let(:run_data) { RecipeRunData.new(motherdough, date: Time.zone.today) }
    it 'adds inclusion info with weights and ingredients for each product inclusion' do
      inclusions = [mock_recipe_run_inclusion(product, inclusion), mock_recipe_run_inclusion(product2, inclusion)]
      allow_any_instance_of(RecipeRunData).to receive(:inclusions).and_return(inclusions)
      run_data.add_recipe_inclusions_info
      inclusion_info = run_data.inclusions_info.first
      total_ingredients_weight = inclusion_info[:ingredients].map { |ingredient| ingredient[:weight] }.sum.round(3)

      expect(inclusion_info[:inclusion]).to eq(inclusion)
      expect(inclusion_info[:dough]).to eq(motherdough)
      expect(inclusion_info[:total_inclusion_weight]).to eq(Unitwise(0.4, :kg))
      expect(inclusion_info[:total_dough_weight]).to eq(Unitwise(1.6, :kg))
      expect(inclusion_info[:total_product_weight]).to eq(Unitwise(2, :kg))
      expect(total_ingredients_weight).to eq(inclusion_info[:total_inclusion_weight])
    end
  end

  describe '#mix_bowl_count' do
    let(:run_data) { RecipeRunData.new(instance_double('recipe'), Time.zone.today) }
    it 'returns a mix_bowl_size if mix_bowl_size was set by a writer' do
      allow_any_instance_of(RecipeRunData).to receive(:weight=).and_return(nil)
      run_data.mix_bowl_count = 3
      expect(run_data.mix_bowl_count).to eq(3)
    end

    it 'calculates a mix_bowl_size if mix_bowl_size was not set by a writer' do
      recipe = instance_double('Recipe', mix_size_with_unit: Unitwise(0, :kg))
      allow_any_instance_of(RecipeRunData).to receive(:weight=).and_return(nil)
      allow_any_instance_of(RecipeRunData).to receive(:recipe).and_return(recipe)
      expect(run_data.mix_bowl_count).to eq(1)
    end
  end

  describe '#products_total_weight' do
    let(:motherdough) { create(:recipe_motherdough) }
    let(:product) { create(:product, motherdough: motherdough, weight: 3, unit: :g) }
    let(:run_data) { RecipeRunData.new(motherdough, date: Time.zone.today) }

    it 'returns the total weights of all the products' do
      product_with_kg_weight = create(:product, motherdough: motherdough, weight: 2, unit: :kg)
      run_data.add_product(product, 1)
      run_data.add_product(product_with_kg_weight, 1)
      expect(run_data.products_total_weight).to eq(Unitwise(2.003, :kg))
    end
  end

  def mock_recipe_run_inclusion(product, inclusion)
    {
      product: product,
      recipe: inclusion,
      inclusion_weight: Unitwise(0.2, :kg),
      dough_weight: Unitwise(0.8, :kg),
      product_weight: Unitwise(1, :kg)
    }
  end
end
