require "rails_helper"

describe DailyTotalPdf do
  it "renders shipments on a date" do
    route = create(:route)
    create_list(:shipment, 2, date: Date.today, shipment_item_count: 2, route_id: route.id)
    create_list(:shipment, 2, date: Date.today, shipment_item_count: 2)

    pdf = DailyTotalPdf.new(Date.today)
    expect(pdf.render).to_not be_nil
  end

  it "renders when there are no shipments" do
    pdf = DailyTotalPdf.new(Date.today)
    expect(pdf.render).to_not be_nil
  end
end
