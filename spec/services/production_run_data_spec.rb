require "rails_helper"

describe ProductionRunData do
  describe "with a nested preferment recipe" do
    it "collects product, motherdough, ingredient, and preferment data for the run" do
      bakery = create(:bakery)
      run_date = Date.new(2026, 6, 2)
      flour = create(:ingredient, bakery: bakery, name: "Strong Flour")
      water = create(:ingredient, bakery: bakery, name: "Filtered Water")
      preferment_flour = create(:ingredient, bakery: bakery, name: "Preferment Flour")
      preferment = create(
        :recipe_preferment,
        bakery: bakery,
        name: "Levain Preferment",
        mix_size: 2,
        mix_size_unit: :kg
      )
      create(:recipe_item_ingredient, bakery: bakery, recipe: preferment, inclusionable: preferment_flour,
                                      bakers_percentage: 100)

      motherdough = create(
        :recipe_motherdough,
        bakery: bakery,
        name: "Country Dough",
        mix_size: 1,
        mix_size_unit: :kg
      )
      create(:recipe_item_ingredient, bakery: bakery, recipe: motherdough, inclusionable: flour,
                                      bakers_percentage: 100, sort_id: 1)
      create(:recipe_item_ingredient, bakery: bakery, recipe: motherdough, inclusionable: water, bakers_percentage: 70,
                                      sort_id: 2)
      create(:recipe_item_recipe, bakery: bakery, recipe: motherdough, inclusionable: preferment,
                                  bakers_percentage: 20, sort_id: 3)

      product = create(
        :product,
        bakery: bakery,
        name: "Country Loaf",
        product_type: :bread,
        weight: 100,
        unit: :g,
        motherdough: motherdough
      )
      production_run = create(:production_run, bakery: bakery, date: run_date)
      create(:run_item, bakery: bakery, production_run: production_run, product: product, order_quantity: 10,
                        overbake_quantity: 2)

      data = ProductionRunData.new(production_run)

      expect(data.products.keys).to eq(["bread"])
      expect(data.products["bread"].first.total_quantity).to eq(12)
      expect(data.recipes.map { |recipe_data|
        recipe_data.recipe.name
      }).to include("Country Dough", "Levain Preferment")
      expect(data.preferments.map { |recipe_data| recipe_data.recipe.name }).to eq(["Levain Preferment"])

      motherdough_data = data.recipes.detect { |recipe_data| recipe_data.recipe == motherdough }
      expect(motherdough_data.products.first[:product]).to eq(product)
      expect(motherdough_data.products.first[:quantity]).to eq(12)
      expect(motherdough_data.ingredients.map { |item|
        item[:inclusionable].name
      }).to eq(["Strong Flour", "Filtered Water"])
      expect(motherdough_data.nested_recipes.first[:inclusionable]).to eq(preferment)

      preferment_data = data.preferments.first
      expect(preferment_data.parent_recipes.first[:parent_recipe]).to eq(motherdough)
      expect(preferment_data.ingredients.first[:inclusionable]).to eq(preferment_flour)
    end
  end

  describe "#add_nested_recipes" do
    let(:bakery) { create(:bakery) }
    let(:motherdough) {
      create(:recipe_motherdough, :with_nested_recipes, :with_ingredients,
             name: "motherdough recipe", recipe_count: 1, bakery: bakery)
    }
    let(:product) { create(:product, motherdough: motherdough, weight: 100, unit: :g, bakery: bakery) }
    let(:run_item) { create(:run_item, order_quantity: 80, overbake_quantity: 20, product: product) }
    let(:production_run) { run_item.production_run }

    it "collects all the relevant recipes" do
      data = ProductionRunData.new(production_run)
      expect(data.recipes_collection.count).to eq(2)
    end
  end

  describe "#set_preferment_bowls" do
    it "sets preferment bowl counts that are in one mother dough" do
      parent_recipes_array = [instance_double("RecipeRunData")]
      preferment_recipe_data = mock_recipe_run_preferment(parent_recipes_array)

      allow_any_instance_of(ProductionRunData).to receive(:preferments).and_return([preferment_recipe_data])
      allow_any_instance_of(RecipeCollection).to receive(:detect).and_return(mock_parent_recipe)
      expect(preferment_recipe_data).to receive(:mix_bowl_count=).with(3)
      ProductionRunData.new(ProductionRun.new)
    end

    it "does not set preferment bowl counts that are in more than one mother dough" do
      parent_recipes_array = [instance_double("RecipeRunData"), instance_double("RecipeRunData")]
      preferment_recipe_data = mock_recipe_run_preferment(parent_recipes_array)

      allow_any_instance_of(ProductionRunData).to receive(:preferments).and_return([preferment_recipe_data])
      allow_any_instance_of(RecipeCollection).to receive(:detect).and_return(mock_parent_recipe)
      expect(preferment_recipe_data).not_to receive(:mix_bowl_count=)
      ProductionRunData.new(ProductionRun.new)
    end
  end

  def mock_recipe_run_preferment(parent_recipes_array)
    instance_double("RecipeRunData",
                    mix_bowl_count: 1,
                    parent_recipes: parent_recipes_array)
  end

  def mock_parent_recipe
    instance_double("RecipeRunData",
                    mix_bowl_count: 3,
                    parent_recipes: [])
  end
end
