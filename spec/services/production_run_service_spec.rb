require 'rails_helper'

describe ProductionRunService do
  let(:bakery) { create(:bakery) }
  let(:today) { Time.zone.today }
  let(:production_run_service) { ProductionRunService.new(bakery) }
  let(:production_run) { production_run_service.production_run }

  describe '.run' do
    it 'creates a new instance of itself for each bakery' do
      bakery
      expect(ProductionRunService).to receive(:new).at_least(:once).and_call_original
      ProductionRunService.run
    end
  end

  describe '#associate_shipment_item' do
    it 'associates shpiment items to the production run' do
      create_list(:shipment_item, 3, production_run: production_run, production_start: today)
      production_run_service.associate_shipment_items

      expect(production_run.shipment_items.any?).to eq(true)
    end
  end

  describe '#create_run_items' do
    it 'creates run items for the shipment items in a production run' do
      create_list(:shipment_item, 3, production_run: production_run)
      ShipmentItem.update_all(production_start: today)

      production_run_service.create_run_items
      expect(production_run.run_items.any?).to eq(true)
    end
  end

  describe '#eligible_shipment_items' do
    it 'finds shipment items for its product that belong to the same bakery' do
      shipment_items = create_list(:shipment_item, 3, bakery: bakery, production_run: nil)
      ShipmentItem.update_all(production_start: today)
      shipment_item = create(:shipment_item)
      items = production_run_service.eligible_shipment_items

      expect(items.include?(shipment_items.first)).to eq(true)
      expect(items.include?(shipment_item)).to eq(false)
    end
  end
end
