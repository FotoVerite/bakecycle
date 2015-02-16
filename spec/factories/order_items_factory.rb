require "faker"

FactoryGirl.define do
  factory :order_item do
    order
    monday { Faker::Number.number(1) }
    tuesday { Faker::Number.number(1) }
    wednesday { Faker::Number.number(1) }
    thursday { Faker::Number.number(1) }
    friday { Faker::Number.number(1) }
    saturday { Faker::Number.number(1) }
    sunday { Faker::Number.number(1) }

    transient do
      bakery { build(:bakery) }
      lead_time 2
    end

    product { create(:product, :with_motherdough, bakery: bakery, lead_time: lead_time) }
  end
end
