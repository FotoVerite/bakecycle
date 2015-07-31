require "rails_helper"

describe PriceVariant do
  let(:price_variant) { build(:price_variant) }

  it "has model attributes" do
    expect(price_variant).to respond_to(:price)
    expect(price_variant).to respond_to(:quantity)
    expect(price_variant).to belong_to(:product)
    expect(price_variant).to belong_to(:client)
  end

  it "validations" do
    expect(price_variant).to validate_numericality_of(:price)
    expect(price_variant).to validate_presence_of(:price)
    expect(price_variant).to validate_numericality_of(:quantity)
    expect(price_variant).to validate_presence_of(:quantity)
  end
end
