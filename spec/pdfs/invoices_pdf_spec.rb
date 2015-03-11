require 'rails_helper'

describe InvoicesPdf do
  it 'renders invoices from a collection of shipments' do
    bakery = create(:bakery)
    create_list(:shipment, 2, bakery: bakery)
    pdf = InvoicesPdf.new(Shipment.all.decorate, bakery)
    expect(pdf.render).to_not be_nil
  end
end
