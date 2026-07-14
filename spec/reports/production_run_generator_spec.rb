# frozen_string_literal: true

require "rails_helper"

describe ProductionRunGenerator do
  it "has a shape" do
    production_run = create(:run_item).production_run
    generator = ProductionRunGenerator.new(production_run)
    expect(generator.filename).to eq("Production-Run-#{production_run.id}-#{production_run.date}.pdf")
    expect(generator.generate).to_not be_nil
  end

  describe "#report_attributes" do
    it "exposes production run identity, size, and tenant for the report.generate span" do
      production_run = create(:run_item).production_run
      generator = ProductionRunGenerator.new(production_run)

      expect(generator.report_attributes).to eq(
        "production_run.id" => production_run.id,
        "production_run.item_count" => production_run.run_items.size,
        "bakery.id" => production_run.bakery_id.to_s
      )
    end

    it "sends bakery.id as a string, matching the frontend's type" do
      production_run = create(:run_item).production_run
      generator = ProductionRunGenerator.new(production_run)

      expect(generator.report_attributes["bakery.id"]).to be_a(String)
    end
  end
end
