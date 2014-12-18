require "faker"

FactoryGirl.define do
  factory :order do
    client
    route
    start_date  { Date.today + Faker::Number.number(1).to_i.days }
    end_date  { Date.today + Faker::Number.number(3).to_i.days }
    note { Faker::Lorem.sentence(1) }
  end
end
