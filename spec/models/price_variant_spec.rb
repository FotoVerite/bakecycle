# frozen_string_literal: true

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
#  removed    :integer          default(0)
#

require "rails_helper"

describe PriceVariant do
  let(:price_variant) { build(:price_variant) }

  it "has model attributes" do
    expect(price_variant).to respond_to(:price)
    expect(price_variant).to respond_to(:quantity)
    expect(price_variant).to belong_to(:product)
    expect(price_variant).to belong_to(:client).optional
  end

  it "validations" do
    expect(price_variant).to validate_numericality_of(:price)
    expect(price_variant).to validate_presence_of(:price)
    expect(price_variant).to validate_numericality_of(:quantity)
    expect(price_variant).to validate_presence_of(:quantity)
  end

  describe "quantity uniqueness" do
    it "rejects a second active variant with the same product/client/quantity" do
      product = create(:product)
      create(:price_variant, product: product, client: nil, quantity: 1)

      duplicate = build(:price_variant, product: product, client: nil, quantity: 1)

      expect(duplicate).to_not be_valid
      expect(duplicate.errors[:quantity]).to include("quantity already exists")
    end

    it "does not count a soft-removed variant as a conflict (regression: a removed override blocked "\
       "re-adding the same product/client/quantity forever)" do
      product = create(:product)
      removed = create(:price_variant, product: product, client: nil, quantity: 1)
      removed.destroy
      expect(removed.reload.removed).to eq(1)

      replacement = build(:price_variant, product: product, client: nil, quantity: 1)

      expect(replacement).to be_valid
    end
  end
end
