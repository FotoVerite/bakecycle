FactoryGirl.define do
  factory :order do
    order_type 'standing'
    start_date  { Time.zone.today - 4.days + Faker::Number.number(1).to_i.days }
    end_date  nil
    bakery

    client { create(:client, bakery: bakery) }
    route { create(:route, bakery: bakery) }

    transient do
      order_item_count 1
      total_lead_days 2
      daily_item_count nil
      product { create(:product, :with_motherdough, bakery: bakery, total_lead_days: total_lead_days) }
    end

    after(:build) do |order, evaluator|
      order.order_items << FactoryGirl.build_list(
        :order_item,
        evaluator.order_item_count,
        product: evaluator.product,
        order: order,
        bakery: evaluator.bakery,
        total_lead_days: evaluator.total_lead_days,
        daily_item_count: evaluator.daily_item_count
      )
    end

    factory :temporary_order do
      order_type 'temporary'
      end_date nil
    end
  end
end
