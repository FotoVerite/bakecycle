require "faker"

FactoryGirl.define do
  factory :shipment do
    client
    route
    date  { Date.today + Faker::Number.number(1).to_i.days }
    bakery

    transient do
      shipment_item_count 1
    end

    after(:build) do |shipment, evaluator|
      shipment.shipment_items << FactoryGirl.build_list(
        :shipment_item, evaluator.shipment_item_count, shipment: shipment
      )
    end
  end
end
