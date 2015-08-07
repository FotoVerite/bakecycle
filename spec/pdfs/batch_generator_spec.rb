require "rails_helper"

describe BatchGenerator do
  it "supports a date range" do
    bakery = create(:bakery)
    generator = BatchGenerator.new(bakery, Time.zone.today, Time.zone.tomorrow)
    expect(generator.filename).to eq("Batch_Recipes_#{Time.zone.today}_#{Time.zone.tomorrow}.pdf")
    expect(generator.generate).to_not be_nil
  end
end
