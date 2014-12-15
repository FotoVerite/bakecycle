require 'faker'

FactoryGirl.define do
  factory :route do
    sequence(:name) { |n| "#{n}#{Faker::Lorem.word}" }
    departure_time { Faker::Time.forward(23, :morning) }
    notes { Faker::Lorem.sentence(1) }
    active 1
  end
end
