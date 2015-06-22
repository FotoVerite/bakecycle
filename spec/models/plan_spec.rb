require 'rails_helper'

describe Plan do
  let(:plan) { build(:plan) }

  it 'has model attributes' do
    expect(plan).to respond_to(:name)
    expect(plan).to respond_to(:display_name)
  end

  it 'has validations' do
    expect(plan).to validate_presence_of(:name)
    expect(plan).to validate_presence_of(:display_name)
  end
end
