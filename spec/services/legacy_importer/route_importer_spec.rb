require 'rails_helper'
require 'legacy_importer'

describe LegacyImporter::RouteImporter do
  let(:bakery) { create(:bakery) }
  let(:importer) { LegacyImporter::RouteImporter.new(bakery, legacy_route) }

  let(:legacy_route) do
    HashWithIndifferentAccess.new(
      route_id: 1,
      route_time: Time.zone.local('2000-01-01 03:00:00 -0500'),
      route_name: 'Afternoon',
      route_notes: 'Truck',
      route_active: 'Y'
    )
  end

  describe '#import!' do
    it 'creates a route out of a legacy_route' do
      route = importer.import!
      expect(route).to be_an_instance_of(Route)
      expect(route).to be_valid
      expect(route).to be_persisted
    end

    it 'updates existing routes' do
      route = importer.import!
      legacy_route[:route_name] = 'New Name'
      updated_route = importer.import!

      expect(updated_route.name).to eq('New Name')
      expect(route).to eql(updated_route)

      route.reload
      expect(route.name).to eq('New Name')
    end
  end
end
