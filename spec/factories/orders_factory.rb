require "faker"

FactoryGirl.define do
  factory :order do
    order_type "standing"
    start_date  { Date.today + Faker::Number.number(1).to_i.days }
    end_date  nil
    bakery

    client { create(:client, bakery: bakery) }
    route { create(:route, bakery: bakery) }

    transient do
      order_item_count 1
      lead_time 2
    end

    after(:build) do |order, evaluator|
      order.order_items << FactoryGirl.build_list(
        :order_item,
        evaluator.order_item_count,
        order: order,
        bakery: evaluator.bakery,
        lead_time: evaluator.lead_time
      )
    end

    factory :temporary_order do
      order_type "temporary"
      end_date nil
    end
  end
end
