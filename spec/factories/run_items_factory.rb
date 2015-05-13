FactoryGirl.define do
  factory :run_item do
    transient do
      bakery { |t| t.association(:bakery) }
      product_product_type { Product.product_types.keys.sample }
    end
    product { |t| t.association(:product, bakery: bakery, product_type: product_product_type) }
    overbake_quantity 0
    order_quantity 0
    production_run { |t| t.association(:production_run, bakery: bakery) }
  end
end
