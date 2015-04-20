require 'rails_helper'

describe RecipeService do
  let(:today) { Time.zone.today }
  let(:tomorrow) { Time.zone.tomorrow }
  let(:bakery) { create(:bakery) }
  let(:recipe_service) { RecipeService.new(today, bakery) }

  describe '#date' do
    it 'returns date' do
      expect(recipe_service.date).to eq(today)
    end
  end

  describe '#bakery' do
    it 'returns bakery' do
      expect(recipe_service.bakery).to eq(bakery)
    end
  end

  describe '#shipments' do
    it 'returns collection of shipments for the date' do
      shipment = create(:shipment, bakery: bakery, date: today)
      create(:shipment, bakery: bakery, date: tomorrow)
      expect(recipe_service.shipments).to contain_exactly(shipment)
    end
  end

  describe '#shipment_items' do
    it 'returns collection of shipment_items that belongs to shipments searched by date' do
      shipments = create_list(:shipment, 2, shipment_item_count: 1, date: today, bakery: bakery)
      items = shipments.map(&:shipment_items).flatten
      create(:shipment)
      expect(recipe_service.shipment_items).to match_array(items)
    end
  end

  describe '#products' do
    it 'returns collection of products from shipment items' do
      create_list(:shipment, 2, date: today, bakery: bakery)
      create(:shipment, date: tomorrow)
      products = Product.all.to_a - [Product.last]
      expect(recipe_service.products).to match_array(products)
    end
  end

  describe '#product_types' do
    it 'returns sorted and uniq value collection of products product types' do
      shipment = create(:shipment, date: today, shipment_item_count: 0, bakery: bakery)
      bread = create(:product, product_type: :bread, bakery: bakery)
      cookie = create(:product, product_type: :cookie, bakery: bakery)
      create(:shipment_item, shipment: shipment, product: bread, bakery: bakery)
      create(:shipment_item, shipment: shipment, product: cookie, bakery: bakery)
      expect(recipe_service.product_types).to match_array(Product.all.pluck(:product_type).sort)
    end
  end

  describe '#routes' do
    it 'returns a ordered collection of routes from shipments' do
      create_list(:shipment, 2, date: today, bakery: bakery)
      route = create(:route, bakery: bakery)
      routes = Route.order('departure_time ASC').to_a - [route]
      expect(recipe_service.routes).to match_array(routes)
    end
  end

  describe '#route_shipment_clients' do
    it 'returns a collection of clients for a particlular shipment route' do
      client1 = create(:client, bakery: bakery)
      client2 = create(:client, bakery: bakery)
      client3 = create(:client, bakery: bakery)
      route = create(:route, bakery: bakery)
      create(:shipment, date: today, shipment_item_count: 0, bakery: bakery, client: client1, route: route)
      create(:shipment, date: today, shipment_item_count: 0, bakery: bakery, client: client2, route: route)
      create(:shipment, date: today, shipment_item_count: 0, bakery: bakery, client: client3)
      expect(recipe_service.route_shipment_clients(route)).to match_array([client1, client2])
      expect(recipe_service.route_shipment_clients(route)).to_not include(client3)
    end
  end

  describe '#product_counts' do
    it 'returns the count of products on each route' do
      am = create(:route, bakery: bakery)
      pm = create(:route, bakery: bakery)
      shipment = create(:shipment, date: today, shipment_item_count: 0, route: am, bakery: bakery)
      shipment_2 = create(:shipment, date: today, shipment_item_count: 0, route: pm, bakery: bakery)
      bread = create(:product, product_type: :bread, bakery: bakery)
      cookie = create(:product, product_type: :cookie, bakery: bakery)
      create(:shipment_item, shipment: shipment, product: bread, product_quantity: 1, bakery: bakery)
      create(:shipment_item, shipment: shipment, product: cookie, product_quantity: 2, bakery: bakery)
      create(:shipment_item, shipment: shipment_2, product: bread, product_quantity: 1, bakery: bakery)
      create(:shipment_item, shipment: shipment_2, product: cookie, product_quantity: 3, bakery: bakery)

      counts = {
        bread.id => {
          am.id => 1,
          pm.id => 1,
          total: 2
        },
        cookie.id => {
          am.id => 2,
          pm.id => 3,
          total: 5
        }
      }

      expect(recipe_service.product_counts).to eq(counts)
    end

    it 'caches the output' do
      create_list(:shipment, 2, date: today)
      expect(recipe_service.product_counts).to be(recipe_service.product_counts)
    end
  end
end
