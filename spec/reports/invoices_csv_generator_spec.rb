require "rails_helper"

describe InvoicesCsvGenerator do
  let(:bakery) { create(:bakery) }
  let(:search_form) do
    ShipmentSearchForm.new(
      client_id: [1, 2, 3],
      product_id: [4, 5, 6],
      date_from: Date.parse("30/12/2015"),
      date_to: Date.parse("30/12/2015")
    )
  end
  let(:generator) { InvoicesCsvGenerator.new(bakery, search_form) }

  it "produces a file and a filename" do
    expect(generator.filename).to eq("invoices.csv")
    expect_any_instance_of(InvoicesCsv).to receive(:generate).and_call_original
    expect(generator.generate).to_not be_nil
  end

  describe "global_id" do
    it "serializes and de-serializes" do
      expect(generator.id).to_not be_nil
      new_generator = InvoicesCsvGenerator.find(generator.id)
      expect(new_generator.bakery).to eq(generator.bakery)
      expect(new_generator.search.to_h).to eq(generator.search.to_h)
    end

    it "serializes and de-serialize via GlobalID" do
      id = generator.to_global_id.to_s
      new_generator = GlobalID::Locator.locate id
      expect(new_generator.bakery).to eq(generator.bakery)
      expect(new_generator.search.to_h).to eq(generator.search.to_h)
    end
  end
end
