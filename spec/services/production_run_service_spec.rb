require "rails_helper"

describe ProductionRunService do
  let(:bakery) { create(:bakery) }
  let(:today) { Time.zone.today }
  let(:service) { ProductionRunService.new(bakery, today) }

  it "creates a production run" do
    service.run
    expect(service.production_run).to be_persisted
    expect(service.production_run).to be_valid
    expect(service.production_run).to be_a(ProductionRun)
  end

  it "updates a production run" do
    create(:shipment, bakery: bakery, date: today + 2.days)
    service.run
    pr = service.production_run
    expect(service.production_run.run_items.count).to eq(1)
    create(:shipment, bakery: bakery, date: today + 2.days)
    service = ProductionRunService.new(bakery, today)
    service.run
    expect(service.production_run.run_items.count).to eq(2)
    expect(pr).to eq(service.production_run)
  end

  describe "#associate_shipment_item" do
    it "associates shipment items to the production run" do
      shipment = create(
        :shipment,
        bakery: bakery,
        shipment_item_count: 3,
        date: today + 2.days,
        total_lead_days: 2
      )
      service.run
      expect(service.production_run.shipment_items).to match_array(shipment.shipment_items)
    end
  end

  describe "#create_run_items" do
    it "creates run items for the shipment items in a production run" do
      create(:shipment, bakery: bakery, shipment_item_count: 1, date: today + 2.days)
      create(:shipment, bakery: bakery, shipment_item_count: 1, date: today + 2.days)
      service.run
      expect(service.production_run.run_items.count).to eq(2)
    end
  end
end
