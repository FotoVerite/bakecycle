require "rails_helper"

describe ProductionRunGenerator do
  it "has a shape" do
    production_run = create(:run_item).production_run
    generator = ProductionRunGenerator.new(production_run)
    expect(generator.filename).to eq("Production-Run-#{production_run.id}-#{production_run.date}.pdf")
    expect(generator.generate).to_not be_nil
  end
end
