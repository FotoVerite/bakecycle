FactoryGirl.define do
  factory :plan do
    sequence(:name) { |n| "beta_sample #{n}" }
    sequence(:display_name) { |n| "sample Bakery#{n}" }
  end
end
