FactoryGirl.define do
  factory :run_item do
    transient do
      bakery { create(:bakery) }
    end

    production_run { create(:production_run, bakery: bakery) }
    product { create(:product, bakery: bakery) }
    overbake_quantity 10
  end
end
