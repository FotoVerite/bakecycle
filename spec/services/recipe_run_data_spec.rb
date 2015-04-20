require 'rails_helper'

describe RecipeRunData do
  describe '#add_product' do
    let(:motherdough) { create(:recipe) }
    let(:inclusion) { create(:recipe) }
    let(:product) { create(:product, motherdough: motherdough, weight: 1, unit: :g) }
    let(:run_data) { RecipeRunData.new(motherdough) }

    it 'keeps a list of products and their info' do
      product_info = {
        product: product,
        quantity: 1,
        weight: Unitwise(1, :g)
      }
      run_data.add_product(product, 1)
      expect(run_data.products).to include(product_info)
    end

    it 'keeps a list of inclusions and their info' do
      product.inclusion = inclusion
      inclusion_info = {
        recipe: inclusion,
        weight: Unitwise(0, :g)
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
      let(:motherdough) { create(:recipe, :with_nested_recipes, :with_ingredients) }

      it 'returns the ingredients from recipe items' do
        expect(run_data.ingredients.count).to eq(3)
        expect(run_data.ingredients.first[:inclusionable]).to be_a(Ingredient)
      end

      it 'returns the recipes from recipe items' do
        expect(run_data.nested_recipes.count).to eq(3)
        expect(run_data.nested_recipes.first[:inclusionable]).to be_a(Recipe)
      end
    end
  end
end
