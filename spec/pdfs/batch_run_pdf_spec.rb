require 'rails_helper'

describe BatchRunPdf do
  it 'renders a batch run when given projection run data' do
    bakery = build_stubbed(:bakery)
    projection = stub_production_run_projection(bakery)
    projection_run_data = ProjectionRunData.new(projection)
    pdf = BatchRunPdf.new(projection_run_data)

    expect(pdf.render).to_not be_nil
  end
end
