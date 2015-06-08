require 'rails_helper'

describe FileExport do
  let(:file_export) { build_stubbed(:file_export) }

  it 'has a shape' do
    expect(file_export).to respond_to(:bakery)
    expect(file_export).to respond_to(:file)
  end
end
