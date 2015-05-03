FactoryGirl.define do
  factory :order_item do
    transient do
      bakery { |t| t.association(:bakery) }
      total_lead_days 2
      daily_item_count nil
    end

    product { |t| t.association(:product, :with_motherdough, bakery: bakery, total_lead_days: total_lead_days) }

    monday    { daily_item_count || Faker::Number.number(1).to_i + 1 }
    tuesday   { daily_item_count || Faker::Number.number(1).to_i + 1 }
    wednesday { daily_item_count || Faker::Number.number(1).to_i + 1 }
    thursday  { daily_item_count || Faker::Number.number(1).to_i + 1 }
    friday    { daily_item_count || Faker::Number.number(1).to_i + 1 }
    saturday  { daily_item_count || Faker::Number.number(1).to_i + 1 }
    sunday    { daily_item_count || Faker::Number.number(1).to_i + 1 }
  end
end
