# frozen_string_literal: true

FactoryBot.define do
  factory :route do
    name { generate(:route_name) }
    departure_time { Faker::Time.forward(days: 23, period: :morning) }
    active { true }
    bakery { create(:bakery) }
  end

  sequence :route_name do |n|
    routes = [
      "Uptown",
      "Downtown",
      "East Side",
      "West Side",
      "Midtown",
      "Early AM"
    ]

    "#{routes.sample} #{n}"
  end
end
