require 'rails_helper'

describe PriceVarient do
  let(:price_varient) { build(:price_varient) }

  it 'has model attributes' do
    expect(price_varient).to respond_to(:price)
    expect(price_varient).to respond_to(:quantity)
    expect(price_varient).to belong_to(:product)
  end

  it 'validations' do
    expect(price_varient).to validate_numericality_of(:price)
    expect(price_varient).to validate_presence_of(:price)
    expect(price_varient).to validate_numericality_of(:quantity)
    expect(price_varient).to validate_presence_of(:quantity)
  end
end
