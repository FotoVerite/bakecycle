require "rails_helper"

describe ProductFormSerializer do
  let(:bakery) { create(:bakery) }
  let(:user) { create(:user, bakery: bakery) }
  let(:product) { create(:product, bakery: bakery) }
  let(:form) { ProductForm.new(product: product, user: user) }

  subject(:hash) { form.serializable_hash }

  it "exposes product as a camelCase string key" do
    expect(hash).to have_key("product")
    expect(hash["product"]).to be_a(Hash)
  end

  it "includes the product id" do
    expect(hash["product"]).to include(id: product.id)
  end

  it "exposes clients as a string-keyed array" do
    expect(hash).to have_key("clients")
    expect(hash["clients"]).to be_an(Array)
  end
end
