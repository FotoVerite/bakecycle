require "rails_helper"

RSpec.describe "bakecycle:update_lead_days", type: :task do
  it "sets preferment recipes to one lead day and touches them" do
    bakery = create(:bakery)
    preferment = create(:recipe_preferment, bakery: bakery)
    dough = create(:recipe_motherdough, bakery: bakery)
    original_timestamp = 2.days.ago.change(usec: 0)
    preferment.update_columns(lead_days: 0, updated_at: original_timestamp)
    dough.update_columns(lead_days: 3, updated_at: original_timestamp)

    expect { rake_task("bakecycle:update_lead_days").invoke }.to output(
      "Starting Task\nLead days updated\n"
    ).to_stdout

    expect(preferment.reload.lead_days).to eq(1)
    expect(preferment.updated_at).to be > original_timestamp
    expect(dough.reload.lead_days).to eq(3)
    expect(dough.updated_at).to eq(original_timestamp)
  end
end
