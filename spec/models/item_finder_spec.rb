require "rails_helper"

describe ItemFinder do
  let(:user) { create(:user) }
  let(:item_finder) { ItemFinder.new(user) }

  it "finds my bakeries" do
    create(:bakery)
    expect(item_finder.bakeries).to contain_exactly(user.bakery)
  end

  it "finds my clients" do
    create(:client)
    client = create(:client, bakery: user.bakery)
    expect(item_finder.clients).to contain_exactly(client)
  end

  it "finds my products" do
    create(:product)
    product = create(:product, bakery: user.bakery)
    expect(item_finder.products).to contain_exactly(product)
  end

  it "finds my ingredients" do
    create(:ingredient)
    ingredient = create(:ingredient, bakery: user.bakery)
    expect(item_finder.ingredients).to contain_exactly(ingredient)
  end

  it "finds my recipes" do
    create(:recipe)
    recipe = create(:recipe, bakery: user.bakery)
    expect(item_finder.recipes).to contain_exactly(recipe)
  end

  it "finds my routes" do
    create(:route)
    route = create(:route, bakery: user.bakery)
    expect(item_finder.routes).to contain_exactly(route)
  end

  it "finds my shipments" do
    create(:shipment)
    shipment = create(:shipment, bakery: user.bakery)
    expect(item_finder.shipments).to contain_exactly(shipment)
  end

  it "finds my orders" do
    create(:order)
    order = create(:order, bakery: user.bakery)
    expect(item_finder.orders).to contain_exactly(order)
  end

  it "finds my users" do
    create(:user)
    other_user = create(:user, bakery: user.bakery)
    expect(item_finder.users).to contain_exactly(user, other_user)
  end
end
