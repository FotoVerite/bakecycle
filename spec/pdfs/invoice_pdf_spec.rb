require 'rails_helper'

describe InvoicePdf do
  it 'renders invoice on a shipment' do
    bakery = create(:bakery)
    shipment = create(:shipment, bakery: bakery)
    pdf = InvoicePdf.new(shipment.decorate, bakery)
    expect(pdf.render).to_not be_nil
  end

  it 'renders invoice on a shipment with a bakery logo' do
    bakery = create(:bakery, :with_logo)
    shipment = create(:shipment, bakery: bakery)
    pdf = InvoicePdf.new(shipment.decorate, bakery)
    expect(pdf.render).to_not be_nil
  end
end
