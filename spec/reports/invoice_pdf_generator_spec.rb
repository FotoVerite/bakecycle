require "rails_helper"

describe InvoicePdfGenerator do
  let(:bakery) { create(:bakery) }
  let(:shipment) { create(:shipment, bakery: bakery) }
  let(:generator) { InvoicePdfGenerator.new(bakery, shipment) }

  it "produces a file and a filename" do
    create_list(:shipment, 2, bakery: bakery)
    expect(generator.filename).to match(/invoice.*\.pdf/)
    expect_any_instance_of(InvoicesPdf).to receive(:render).and_call_original
    expect(generator.generate).to_not be_nil
  end

  it "produces a file and filename when there are no shipments" do
    expect(generator.filename).to match(/invoice.*\.pdf/)
    expect_any_instance_of(InvoicesPdf).to receive(:render).and_call_original
    expect(generator.generate).to_not be_nil
  end

  describe "global_id" do
    it "serializes and de-serializes" do
      expect(generator.id).to_not be_nil
      new_generator = InvoicePdfGenerator.find(generator.id)
      expect(new_generator.bakery).to eq(generator.bakery)
      expect(new_generator.shipment).to eq(generator.shipment)
    end

    it "serializes and de-serialize via GlobalID" do
      id = generator.to_global_id.to_s
      new_generator = GlobalID::Locator.locate id
      expect(new_generator.bakery).to eq(generator.bakery)
      expect(new_generator.shipment).to eq(generator.shipment)
    end
  end
end
