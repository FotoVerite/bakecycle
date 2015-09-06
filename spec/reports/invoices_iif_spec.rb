require "rails_helper"

describe InvoicesIif do
  it "renders invoices from a collection of shipments" do
    create_list(:shipment, 2)
    iif = InvoicesIif.new(Shipment.all)
    expect(iif.generate).to_not be_nil
  end
end
