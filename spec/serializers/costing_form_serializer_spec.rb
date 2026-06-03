require "rails_helper"

describe CostingFormSerializer do
  let(:bakery) { create(:bakery) }
  let(:user) { create(:user, bakery: bakery) }
  let(:ingredients) { create_list(:ingredient, 2, bakery: bakery) }
  let(:form) { CostingForm.new(ingredients: ingredients, user: user) }

  subject(:hash) { form.serializable_hash }

  it "exposes ingredients as a camelCase string key" do
    expect(hash).to have_key("ingredients")
    expect(hash["ingredients"]).to be_an(Array)
  end

  it "sets dirty: false on each ingredient" do
    hash["ingredients"].each do |i|
      expect(i["dirty"]).to eq(false)
    end
  end

  it "includes filter key" do
    expect(hash).to have_key("filter")
    expect(hash["filter"]).to eq([])
  end

  it "includes weightUnitOptions key" do
    expect(hash).to have_key("weightUnitOptions")
    expect(hash["weightUnitOptions"]).to be_an(Array)
  end

  it "exposes availableVendors as a camelCase array" do
    expect(hash).to have_key("availableVendors")
    expect(hash["availableVendors"]).to be_an(Array)
  end
end
