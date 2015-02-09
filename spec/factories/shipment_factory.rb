require "faker"

FactoryGirl.define do
  factory :shipment do
    date  { Date.today + Faker::Number.number(1).to_i.days }
    bakery

    client { create(:client, bakery: bakery) }
    route { create(:route, bakery: bakery) }

    transient do
      shipment_item_count 1
    end

    after(:build) do |shipment, evaluator|
      shipment.shipment_items << FactoryGirl.build_list(
        :shipment_item,
        evaluator.shipment_item_count,
        shipment: shipment,
        bakery: evaluator.bakery
      )
    end
  end
end
