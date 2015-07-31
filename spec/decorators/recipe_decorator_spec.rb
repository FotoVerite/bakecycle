require "rails_helper"

describe RecipeDecorator do
  let(:recipe) { build_stubbed(:recipe) }
  let(:recipe_decorator) { RecipeDecorator.new(recipe) }

  it "items" do
    sugar = create(:ingredient, name: "Sugar")
    allow(recipe_decorator).to receive(:ingredients).and_return(sugar)

    ciabatta = create(:recipe, name: "Ciabatta")
    allow(recipe_decorator).to receive(:recipes).and_return(ciabatta)

    inclusions = [
      [ciabatta.name, "#{ciabatta.id}-#{ciabatta.class}"],
      [sugar.name, "#{sugar.id}-#{sugar.class}"]
    ]

    ingredients = [
      [sugar.name, "#{sugar.id}-#{sugar.class}"]
    ]

    expect(recipe_decorator.available_inclusions).to eq(inclusions)
    expect(recipe_decorator.available_ingredients).to eq(ingredients)
  end
end
