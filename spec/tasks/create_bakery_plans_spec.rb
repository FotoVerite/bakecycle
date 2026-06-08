# frozen_string_literal: true

require "rails_helper"

RSpec.describe "bakecycle:create_plans", type: :task do
  it "creates the beta bakery plans idempotently" do
    task = rake_task("bakecycle:create_plans")

    expect { task.invoke }.to output("Plans Created\n").to_stdout
      .and change(Plan, :count).by(3)
    expect(Plan.pluck(:name)).to include("beta_large", "beta_medium", "beta_small")

    task.reenable
    expect { task.invoke }.to output("Plans Created\n").to_stdout
    expect(Plan.count).to eq(3)
  end
end
