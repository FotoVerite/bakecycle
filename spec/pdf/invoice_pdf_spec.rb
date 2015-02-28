require "rails_helper"

describe InvoicePdf do
  it "renders invoice on a shipment" do
    shipment = create(:shipment)
    pdf = InvoicePdf.new(shipment.decorate)
    expect(pdf.render).to_not be_nil
  end

  it "renders invoice on a shipment with a bakery logo" do
    shipment = create(:shipment, bakery: create(:bakery, :with_logo))
    pdf = InvoicePdf.new(shipment.decorate)
    expect(pdf.render).to_not be_nil
  end
end
