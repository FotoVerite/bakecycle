require 'rails_helper'

describe DailyTotalPdf do
  let(:bakery) { create(:bakery) }
  let(:today) { Time.zone.today }

  it 'renders shipments on a date' do
    route = create(:route, bakery: bakery)
    create_list(:shipment, 2, date: today, shipment_item_count: 2, route: route, bakery: bakery)
    create_list(:shipment, 2, date: today, shipment_item_count: 2)

    pdf = DailyTotalPdf.new(today, bakery)
    expect(pdf.render).to_not be_nil
  end

  it 'renders when there are no shipments' do
    pdf = DailyTotalPdf.new(today, bakery)
    expect(pdf.render).to_not be_nil
  end
end
