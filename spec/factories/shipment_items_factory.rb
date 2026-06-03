FactoryBot.define do
  factory :shipment_item do
    transient do
      bakery { create(:bakery) }
      total_lead_days { 2 }
    end
    shipment { create(:shipment, bakery: bakery) }
    product { create(:product, bakery: bakery, total_lead_days: total_lead_days) }
    product_quantity { Faker::Number.number(digits: 2) }
    product_price { Faker::Number.decimal(l_digits: 2) }
  end
end
