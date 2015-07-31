require "rails_helper"

describe Week do
  let(:today) { Time.zone.today }

  context "creates week model" do
    it "creates a model containing a start_date and end_date" do
      week = Week.new(today)
      expect(week.end_date).to eq(today)
      expect(week.start_date).to eq(today - 6)
    end
  end
end
