# frozen_string_literal: true

FactoryBot.define do
  factory :user_pinned_action do
    user
    sequence(:action_key) { |n| PinnedActionRegistry.keys[n % PinnedActionRegistry.keys.length] }
    sequence(:position)
  end
end
