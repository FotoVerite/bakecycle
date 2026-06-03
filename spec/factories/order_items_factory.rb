FactoryBot.define do
  factory :order_item do
    transient do
      bakery { create(:bakery) }
      force_total_lead_days { 2 }
      daily_item_count { nil }
    end
    order { create(:order, order_item_count: 0, bakery: bakery) }
    product do
      create(
        :product,
        :with_motherdough,
        bakery: bakery,
        force_total_lead_days: force_total_lead_days
      )
    end

    monday    { daily_item_count || Faker::Number.number(digits: 2).to_i + 1 }
    tuesday   { daily_item_count || Faker::Number.number(digits: 2).to_i + 1 }
    wednesday { daily_item_count || Faker::Number.number(digits: 2).to_i + 1 }
    thursday  { daily_item_count || Faker::Number.number(digits: 2).to_i + 1 }
    friday    { daily_item_count || Faker::Number.number(digits: 2).to_i + 1 }
    saturday  { daily_item_count || Faker::Number.number(digits: 2).to_i + 1 }
    sunday    { daily_item_count || Faker::Number.number(digits: 2).to_i + 1 }
  end
end
