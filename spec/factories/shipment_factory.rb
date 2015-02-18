require "faker"

FactoryGirl.define do
  factory :shipment do
    date  { Date.today + Faker::Number.number(1).to_i.days }
    bakery
    route { create(:route, bakery: bakery) }
    client { create(:client, bakery: bakery) }
    note { Faker::Lorem.sentence(1) }

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

    trait :with_delivery_fee do
      delivery_fee { Faker::Number.decimal(2) }
    end
  end
end
