require "rails_helper"

describe Bakery do
  let(:bakery) { build(:bakery) }

  it "has model attributes" do
    expect(bakery).to respond_to(:name)
    expect(bakery).to respond_to(:ingredients)
    expect(bakery).to respond_to(:clients)
    expect(bakery).to respond_to(:recipes)
    expect(bakery).to respond_to(:orders)
    expect(bakery).to respond_to(:products)
    expect(bakery).to respond_to(:routes)
    expect(bakery).to respond_to(:shipments)
    expect(bakery).to respond_to(:users)
  end

  it "has validations" do
    expect(bakery).to validate_presence_of(:name)
    expect(bakery).to ensure_length_of(:name).is_at_most(150)
    expect(bakery).to validate_uniqueness_of(:name)
  end
end
