FactoryGirl.define do
  factory :order do
    order_type 'standing'
    start_date  { Time.zone.today - 4.days + Faker::Number.number(1).to_i.days }
    end_date  nil
    bakery

    client { |t| t.association(:client, bakery: bakery) }
    route { |t| t.association(:route, bakery: bakery) }

    transient do
      order_item_count 1
      product_total_lead_days 2
      daily_item_count nil
      product_batch_recipe true
      product { |t|
        t.association(
          :product,
          :with_motherdough,
          bakery: bakery,
          force_total_lead_days: product_total_lead_days,
          batch_recipe: product_batch_recipe
        )
      }
    end

    order_items do |t|
      order_item_count.times.map do
        t.association(
          :order_item,
          product: product,
          bakery: bakery,
          order: t.instance_variable_get(:@instance),
          daily_item_count: daily_item_count
        )
      end
    end

    trait :active do
      start_date  { Time.zone.today - 4.days }
    end

    trait :inactive do
      start_date  { Time.zone.today - 2.weeks }
      end_date  { Time.zone.today - 1.week }
    end

    factory :temporary_order do
      order_type 'temporary'
      end_date nil
    end
  end
end
