require "rails_helper"

describe "factories" do
  it "lints the base factories with the create strategy" do
    FactoryBot.lint(traits: false)
  end
end
