require 'rails_helper'

describe BatchRunPdf do
  it 'renders a batch run when given projection run data' do
    projection = new_stubed_production_run_projection
    projection_run_data = ProjectionRunData.new(projection)
    pdf = BatchRunPdf.new(projection_run_data)
    expect(pdf.render).to_not be_nil
  end
end
