require "faker"

FactoryGirl.define do
  factory :order do
    client
    route
    order_type "standing"
    start_date  { Date.today + Faker::Number.number(1).to_i.days }
    end_date  { Date.today + Faker::Number.number(3).to_i.days }

    transient do
      order_item_count 1
    end

    after(:build) do |order, evaluator|
      order.order_items << FactoryGirl.build_list(:order_item, evaluator.order_item_count, order: order)
    end

    factory :temporary_order do
      order_type "temporary"
      end_date nil
    end
  end
end
