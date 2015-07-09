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
    projection = new_stubed_production_run_projection
    projection_run_data = ProjectionRunData.new(projection)
    pdf = ProductionRunPdf.new(projection_run_data)

    expect(pdf.render).to_not be_nil
  end
end
