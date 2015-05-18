require 'rails_helper'
require 'legacy_importer'

describe LegacyImporter::OrderImporter do
  let(:bakery) { create(:bakery) }
  let(:items) { double(LegacyImporter::OrderItemsBuilder, items_for: [build(:order_item, bakery: bakery)]) }
  let(:client) { create(:client, bakery: bakery, legacy_id: '2') }
  let(:route) { create(:route, bakery: bakery, legacy_id: '2') }

  let(:importer) do
    LegacyImporter::OrderImporter.new(
      bakery,
      legacy_order,
      items_builder: items
    )
  end

  let(:legacy_order) do
    {
      order_id: 1,
      order_clientid: client.legacy_id,
      order_routeid: route.legacy_id,
      order_type: 'standing',
      order_startdate: Time.zone.today,
      order_enddate: Time.zone.tomorrow,
      order_notes: 'Go long and throw it down the stairs',
      order_deleted: 'N'
    }
  end

  before do
    mock_connection = instance_double(
      Mysql2::Client,
      query: [],
      escape: ''
    )
    LegacyImporter::DB.connection(connection: mock_connection)
  end

  describe '#import!' do
    it 'creates a recipe out of a legacy_order' do
      order = importer.import!
      expect(order).to be_an_instance_of(Order)
      expect(order).to be_valid
      expect(order).to be_persisted
    end

    it 'returns unsuccessful import' do
      legacy_order[:order_enddate] = Time.zone.yesterday
      order = importer.import!
      expect(order).to_not be_valid
      expect(order).to_not be_persisted
    end

    it 'updates existing orders' do
      order = importer.import!
      legacy_order[:order_notes] = 'Something'
      updated_order = importer.import!

      expect(updated_order.note).to eq('Something')
      expect(order).to eql(updated_order)
      order.reload
      expect(order.note).to eq('Something')
    end
  end
end
