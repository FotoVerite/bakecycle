FactoryGirl.define do
  factory :shipment do
    date  { Time.zone.today + Faker::Number.number(1).to_i.days }
    bakery
    route { |t| t.association(:route, bakery: bakery) }
    client { |t| t.association(:client, bakery: bakery) }
    note { Faker::Lorem.sentence(1) }

    transient do
      shipment_item_count 1
      total_lead_days 2
      product { |t| t.association(:product, :with_motherdough, bakery: bakery, total_lead_days: total_lead_days) }
    end

    shipment_items do |t|
      Array.new(shipment_item_count) do
        t.association(
          :shipment_item,
          shipment: t.instance_variable_get(:@instance),
          product: product,
          bakery: bakery
        )
      end
    end

    trait :with_delivery_fee do
      delivery_fee { Faker::Number.decimal(2) }
    end
  end
end
