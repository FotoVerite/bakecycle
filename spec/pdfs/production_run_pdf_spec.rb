require 'rails_helper'

describe ProductionRunPdf do
  it 'renders a production run with a production run' do
    production_run = build_stubbed(:production_run)
    build_stubbed(:run_item, production_run: production_run, order_quantity: 5)
    production_run_data = ProductionRunData.new(production_run)
    pdf = ProductionRunPdf.new(production_run_data)
    expect(pdf.render).to_not be_nil
  end

  it 'renders a production run with a projection run' do
    order_item = build_stubbed(:order_item)
    bakery = order_item.order.bakery
    allow_any_instance_of(ProductionRunProjection).to receive(:order_items).and_return([order_item])
    allow_any_instance_of(Product).to receive(:total_lead_days).and_return(1)
    allow_any_instance_of(Recipe).to receive(:total_lead_days).and_return(1)

    projection = ProductionRunProjection.new(bakery, Time.zone.now)
    projection_run_data = ProjectionRunData.new(projection)
    pdf = ProductionRunPdf.new(projection_run_data)

    expect(pdf.render).to_not be_nil
  end
end
