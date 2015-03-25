FactoryGirl.define do
  factory :order_item do
    order
    monday { Faker::Number.number(1).to_i + 1 }
    tuesday { Faker::Number.number(1).to_i + 1 }
    wednesday { Faker::Number.number(1).to_i + 1 }
    thursday { Faker::Number.number(1).to_i + 1 }
    friday { Faker::Number.number(1).to_i + 1 }
    saturday { Faker::Number.number(1).to_i + 1 }
    sunday { Faker::Number.number(1).to_i + 1 }

    transient do
      bakery { build(:bakery) }
      total_lead_days 2
    end

    product { create(:product, :with_motherdough, bakery: bakery, total_lead_days: total_lead_days) }
  end
end
