require 'rails_helper'
require 'legacy_importer'

describe LegacyImporter do
  let(:bakery) { create(:bakery) }
  let(:connection) { instance_double(Mysql2::Client, query: []) }
  let(:importer) { LegacyImporter.new(bakery: bakery, connection: connection) }

  describe '#clients' do
    it 'creates a LegacyClientImporter object with connection object' do
      client_importer = importer.clients
      expect(client_importer).to be_an_instance_of(LegacyClientImporter)
      expect(client_importer.connection).to eq(connection)
      expect(client_importer.bakery).to eq(bakery)
    end
  end

  describe '#ingredients' do
    it 'creates a LegacyClientImporter object with connection object' do
      client_importer = importer.ingredients
      expect(client_importer).to be_an_instance_of(LegacyIngredientImporter)
      expect(client_importer.connection).to eq(connection)
      expect(client_importer.bakery).to eq(bakery)
    end
  end
end
