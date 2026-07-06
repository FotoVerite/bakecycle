# frozen_string_literal: true

require "rails_helper"

describe BakeLeadDayVariant do
  it "requires a client" do
    variant = build(:bake_lead_day_variant, client: nil)
    expect(variant).to_not be_valid
    expect(variant.errors[:client]).to be_present
  end

  it "requires bake_lead_days to be a non-negative integer" do
    variant = build(:bake_lead_day_variant, bake_lead_days: nil)
    expect(variant).to_not be_valid

    variant.bake_lead_days = -1
    expect(variant).to_not be_valid

    variant.bake_lead_days = 0
    expect(variant).to be_valid
  end

  it "only allows one override per product/client pair" do
    product = create(:product)
    client = create(:client, bakery: product.bakery)
    create(:bake_lead_day_variant, product: product, client: client)

    duplicate = build(:bake_lead_day_variant, product: product, client: client)
    expect(duplicate).to_not be_valid
  end

  it "soft-deletes instead of destroying" do
    variant = create(:bake_lead_day_variant)
    variant.destroy
    expect(BakeLeadDayVariant.unscoped.find(variant.id).removed).to eq(1)
  end

  it "does not count a soft-removed override as a conflict (regression: a removed override blocked "\
     "re-adding one for the same product/client forever)" do
    product = create(:product)
    client = create(:client, bakery: product.bakery)
    removed = create(:bake_lead_day_variant, product: product, client: client)
    removed.destroy
    expect(removed.reload.removed).to eq(1)

    replacement = build(:bake_lead_day_variant, product: product, client: client)

    expect(replacement).to be_valid
  end
end
