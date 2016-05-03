require "rails_helper"

describe DeliveryListGenerator do
  it "supports a date range" do
    bakery = create(:bakery)
    generator = DeliveryListGenerator.new(bakery, Time.zone.today)
    expect(generator.filename).to match(/delivery_list_(.+)\.pdf/)
    expect(generator.generate).to_not be_nil
  end
end
