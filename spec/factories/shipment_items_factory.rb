FactoryGirl.define do
  factory :shipment_item do
    transient do
      bakery { |t| t.association(:bakery) }
      total_lead_days 2
    end
    shipment { |t| t.association(:shipment, bakery: bakery) }
    product { |t| t.association(:product, bakery: bakery, total_lead_days: total_lead_days) }
    product_quantity { Faker::Number.number(2) }
    product_price { Faker::Number.decimal(2) }
  end
end
