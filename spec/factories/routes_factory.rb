FactoryGirl.define do
  factory :route do
    name { generate(:route_name) }
    departure_time { Faker::Time.forward(23, :morning) }
    active true
    bakery
  end

  sequence :route_name do |n|
    routes = [
      "Uptown",
      "Downtown",
      "East Side",
      "West Side",
      "Midtown"
    ]

    "#{routes.sample} #{n}"
  end
end
