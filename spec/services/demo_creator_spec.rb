require 'rails_helper'

describe DemoCreator do
  it 'can import from the current yml' do
    bakery = create(:bakery)
    DemoCreator.new(bakery).run
  end

  it 'can recreate data' do
    bakery = create(:bakery)
    create(:order, bakery: bakery)
    create(:recipe, bakery: bakery)

    export = DemoExporter.new(bakery).export

    new_bakery = create(:bakery)
    creator = DemoCreator.new(new_bakery)
    allow(creator).to receive(:demo_data).and_return(export)
    creator.run
    expect(bakery.products.count).to eq(new_bakery.products.count)
    expect(bakery.recipes.count).to eq(new_bakery.recipes.count)
    expect(bakery.orders.count).to eq(new_bakery.orders.count)
    expect(bakery.ingredients.count).to eq(new_bakery.ingredients.count)
    expect(bakery.routes.count).to eq(new_bakery.routes.count)
    expect(bakery.clients.count).to eq(new_bakery.clients.count)
  end
end
