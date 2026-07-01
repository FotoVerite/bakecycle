# frozen_string_literal: true

require "rails_helper"

describe DeliveryListGenerator do
  it "supports a date range" do
    bakery = create(:bakery)
    generator = DeliveryListGenerator.new(bakery, Time.zone.today, "pdf")
    expect(generator.filename).to match(/Delivery-List-(.+)\.pdf/)
    expect(generator.generate).to_not be_nil
  end
end
