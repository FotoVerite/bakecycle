require 'rails_helper'

describe PackingSlipsPdf do
  it 'renders invoices from a collection of shipments' do
    bakery = build_stubbed(:bakery)
    build_stubbed_list(:shipment, 2, bakery: bakery)
    pdf = PackingSlipsPdf.new(Shipment.all, bakery, true)
    expect(pdf.render).to_not be_nil
  end
end
