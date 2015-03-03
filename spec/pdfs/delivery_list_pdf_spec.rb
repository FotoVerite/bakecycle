require 'rails_helper'

describe DeliveryListPdf do
  let(:bakery) { create(:bakery) }

  it 'renders shipments clients on a date' do
    route = create(:route, bakery: bakery)
    create_list(:shipment, 2, date: Date.today, shipment_item_count: 2, route_id: route.id, bakery: bakery)
    create_list(:shipment, 2, date: Date.today, shipment_item_count: 2)

    pdf = DeliveryListPdf.new(Date.today, bakery)
    expect(pdf.render).to_not be_nil
  end

  it 'renders when there are no shipments clients' do
    pdf = DeliveryListPdf.new(Date.today, bakery)
    expect(pdf.render).to_not be_nil
  end
end
