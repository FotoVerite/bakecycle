require "rails_helper"

describe DailyTotalPdf do
  let(:bakery) { create(:bakery) }
  let(:today) { Date.new(2026, 6, 2) }

  it "renders product totals, overbake, and route counts as parseable text" do
    route = create(:route, bakery: bakery, name: "Early AM", departure_time: Time.zone.parse("6:00 AM"))
    product = create(
      :product,
      bakery: bakery,
      name: "Morning Baguette",
      product_type: :bread,
      weight: 1,
      unit: :kg
    )
    production_run = create(:production_run, bakery: bakery, date: today)
    create(:run_item, bakery: bakery, production_run: production_run, product: product, order_quantity: 5,
                      overbake_quantity: 2)
    shipment = create(:shipment, bakery: bakery, route: route, date: today)
    create(
      :shipment_item,
      bakery: bakery,
      shipment: shipment,
      product: product,
      production_run: production_run,
      product_quantity: 5,
      product_price: 2.00
    )

    text = pdf_text(DailyTotalPdf.new(bakery, today).render)

    expect(text).to include("Daily Totals")
    expect(text).to include("Tue Jun. 2, 2026")
    expect(text).to include("Bread")
    expect(text).to include("Morning Baguette")
    expect(text).to include("Early Am")
    expect(text).to match(/Morning Baguette\s+7\s+2\s+5/)
  end

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
