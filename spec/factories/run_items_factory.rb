FactoryGirl.define do
  factory :run_item do
    transient do
      bakery { |t| t.association(:bakery) }
    end
    product { |t| t.association(:product, bakery: bakery) }
    overbake_quantity 0
    order_quantity 0
  end
end
