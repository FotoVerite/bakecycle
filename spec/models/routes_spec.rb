require "rails_helper"

describe Route do
  let(:route) { build(:route) }

  it "has model attributes" do
    expect(route).to respond_to(:name)
    expect(route).to respond_to(:notes)
    expect(route).to respond_to(:active)
    expect(route).to respond_to(:departure_time)
  end

  it "has validations" do
    expect(route).to validate_presence_of(:name)
    expect(route).to ensure_length_of(:name).is_at_most(150)
    expect(route).to validate_presence_of(:departure_time)
  end

  it "it is a time" do
    expect(build(:route, departure_time: Time.now)).to be_valid
    expect(build(:route, departure_time: "it is not a time")).to_not be_valid
  end
end
