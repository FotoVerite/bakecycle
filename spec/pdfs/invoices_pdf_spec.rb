require 'rails_helper'

describe InvoicesPdf do
  it 'renders invoices from a collection of shipments' do
    create_list(:shipment, 2)
    pdf = InvoicesPdf.new(Shipment.all.decorate)
    expect(pdf.render).to_not be_nil
  end
end
