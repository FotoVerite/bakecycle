require "rails_helper"

describe Route do
  let(:route) { build(:route) }

  it "has a shape" do
    expect(route).to respond_to(:name)
    expect(route).to respond_to(:notes)
    expect(route).to respond_to(:active)
    expect(route).to respond_to(:departure_time)
    expect(route).to belong_to(:bakery)
  end

  it "has validations" do
    expect(route).to validate_presence_of(:name)
    expect(route).to validate_presence_of(:departure_time)
    expect(build(:route)).to validate_uniqueness_of(:name).scoped_to(:bakery_id)
  end
end
