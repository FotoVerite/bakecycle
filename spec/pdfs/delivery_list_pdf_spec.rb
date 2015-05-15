require 'rails_helper'

describe DeliveryListPdf do
  let(:bakery) { build_stubbed(:bakery) }
  let(:today) { Time.zone.today }

  it 'renders shipments clients on a date' do
    build_stubbed_list(:shipment, 2, date: today, shipment_item_count: 2, bakery: bakery)
    pdf = DeliveryListPdf.new(today, bakery)
    expect(pdf.render).to_not be_nil
  end

  it 'renders when there are no shipments clients' do
    pdf = DeliveryListPdf.new(today, bakery)
    expect(pdf.render).to_not be_nil
  end
end
