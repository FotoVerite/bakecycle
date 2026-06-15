# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPinnedAction do
  subject(:pin) { build(:user_pinned_action, action_key: "reports") }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:action_key) }
  it { is_expected.to validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0) }

  it "only accepts registered action keys" do
    pin.action_key = "destroy_everything"

    expect(pin).not_to be_valid
    expect(pin.errors[:action_key]).to include("is not included in the list")
  end

  it "prevents duplicate actions for one user" do
    existing = create(:user_pinned_action, action_key: "reports")
    duplicate = build(:user_pinned_action, user: existing.user, action_key: "reports")

    expect(duplicate).not_to be_valid
  end

  it "limits each user to five pins" do
    user = create(:user)
    PinnedActionRegistry.keys.first(5).each_with_index do |action_key, position|
      create(:user_pinned_action, user: user, action_key: action_key, position: position)
    end

    sixth_pin = build(:user_pinned_action, user: user, action_key: PinnedActionRegistry.keys.fetch(5))

    expect(sixth_pin).not_to be_valid
    expect(sixth_pin.errors[:base]).to include("You can pin up to 5 actions.")
  end
end
