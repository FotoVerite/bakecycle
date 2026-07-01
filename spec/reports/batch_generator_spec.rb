# frozen_string_literal: true

require "rails_helper"

describe BatchGenerator do
  it "supports a date range" do
    bakery = create(:bakery)
    generator = BatchGenerator.new(bakery, Time.zone.today, Time.zone.tomorrow)
    expect(generator.filename).to eq("Batch-Recipes-#{Time.zone.today.iso8601}-to-#{Time.zone.tomorrow.iso8601}.pdf")
    expect(generator.generate).to_not be_nil
  end
end
