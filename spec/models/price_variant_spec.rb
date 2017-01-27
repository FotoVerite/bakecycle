# == Schema Information
#
# Table name: price_variants
#
#  id         :integer          not null, primary key
#  product_id :integer          not null
#  price      :decimal(, )      default(0.0), not null
#  quantity   :integer          not null
#  created_at :datetime
#  updated_at :datetime
#  client_id  :integer
#

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
