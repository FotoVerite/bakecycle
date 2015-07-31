require "rails_helper"

describe DailyTotalPdf do
  let(:bakery) { build_stubbed(:bakery) }
  let(:today) { Time.zone.today }

  it "renders shipments on a date" do
    route = build_stubbed(:route, bakery: bakery)
    build_stubbed_list(:shipment, 2, date: today, shipment_item_count: 2, route: route, bakery: bakery)
    build_stubbed_list(:shipment, 2, date: today, shipment_item_count: 2)

    pdf = DailyTotalPdf.new(bakery, today)
    expect(pdf.render).to_not be_nil
  end

  it "renders when there are no shipments" do
    pdf = DailyTotalPdf.new(bakery, today)
    expect(pdf.render).to_not be_nil
  end
end
