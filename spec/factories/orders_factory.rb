# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    order_type { "standing" }
    start_date { Time.zone.today - 4.days + Faker::Number.number(digits: 2).to_i.days }
    end_date { nil }
    bakery { create(:bakery) }

    client { create(:client, bakery: bakery) }
    route { create(:route, bakery: bakery) }

    transient do
      order_item_count { 0 }
      force_total_lead_days { 2 }
      daily_item_count { nil }
    end

    after(:create) do |order, evaluator|
      next if evaluator.order_item_count.zero?

      create_list(
        :order_item,
        evaluator.order_item_count,
        force_total_lead_days: evaluator.force_total_lead_days,
        bakery: order.bakery,
        order: order,
        daily_item_count: evaluator.daily_item_count
      )
      order.reload
    end

    trait :active do
      start_date  { Time.zone.today - 4.days }
    end

    trait :inactive do
      start_date  { Time.zone.today - 2.weeks }
      end_date { Time.zone.today - 1.week }
    end

    trait :with_items do
      transient do
        order_item_count { 1 }
      end
    end

    factory :temporary_order do
      order_type { "temporary" }
      end_date { nil }
    end
  end
end
