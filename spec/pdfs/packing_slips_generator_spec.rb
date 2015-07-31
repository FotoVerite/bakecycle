require "rails_helper"

describe PackingSlipsGenerator do
  it "supports a date range" do
    bakery = create(:bakery)
    generator = PackingSlipsGenerator.new(bakery, Time.zone.today, true)
    expect(generator.filename).to match(/packing_slips_(.+)\.pdf/)
    expect(generator.generate).to_not be_nil
  end
end
