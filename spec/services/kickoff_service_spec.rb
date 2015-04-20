require 'rails_helper'

describe KickoffService do
  let(:today) { Time.zone.today }
  let(:bakery) { create(:bakery) }
  let(:after_kickoff_time) do
    kickoff = bakery.kickoff_time + 1.hour
    Time.zone.local(today.year, today.month, today.day, kickoff.hour, kickoff.min, kickoff.sec)
  end
  let(:shipment_service) { double(ShipmentService, run: true) }
  let(:production_service) { double(ProductionRunService, create_production_run: true) }
  let(:kickoff_service) { KickoffService.new(bakery, after_kickoff_time) }

  before do
    allow(ShipmentService).to receive(:new).and_return(shipment_service)
    allow(ProductionRunService).to receive(:new).and_return(production_service)
  end

  describe '.run' do
    it 'creates a new instance of itself for each bakery' do
      bakery
      expect(KickoffService).to receive(:new).at_least(:once).and_call_original
      KickoffService.run
    end
  end

  describe '#run' do
    it 'calls creates and calls run for ShipmentService and ProductionRunService' do
      allow_any_instance_of(Bakery).to receive(:shipments).and_return(true)
      allow_any_instance_of(KickoffService).to receive(:kickoff?).and_return(true)
      expect(ShipmentService).to receive(:new).and_call_original
      expect(ProductionRunService).to receive(:new).and_call_original
      KickoffService.new(bakery).run
    end
  end

  describe '#kickoff?' do
    it 'returns false if before kickoff time' do
      current_time = bakery.kickoff_time - 1.hour
      shipment_service = KickoffService.new(bakery, current_time)
      expect(shipment_service.kickoff?).to eq(false)
    end

    it 'returns false if last_kickoff is within 24 hours' do
      bakery.last_kickoff = after_kickoff_time - 4.hours
      expect(kickoff_service.kickoff?).to eq(false)
    end

    it 'returns true if last_kickoff is outside of 24 hours' do
      bakery.last_kickoff = after_kickoff_time - 25.hours
      expect(kickoff_service.kickoff?).to eq(true)
    end
  end
end
