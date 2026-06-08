# frozen_string_literal: true

FactoryBot.define do
  factory :plan do
    sequence(:name) { |n| "beta_sample_#{n}" }
    sequence(:display_name) { |n| "Plan ##{n}" }
  end
end
