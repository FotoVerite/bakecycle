FactoryGirl.define do
  factory :product do
    name { generate(:product_name) }
    product_type { Product.product_type_options.sample }
    description { Faker::Lorem.sentence(1) }
    weight { Faker::Number.decimal(0, 3) }
    unit { Product.unit_options.sample }
    extra_amount { Faker::Number.decimal(0, 3) }
    base_price { Faker::Number.decimal(2) }
    bakery

    transient do
      lead_time 2
    end

    trait :with_inclusion do
      inclusion { create(:recipe_inclusion, bakery: bakery, lead_days: lead_time) }
    end

    trait :with_motherdough do
      inclusion { create(:recipe_motherdough, bakery: bakery, lead_days: lead_time) }
    end

    trait :with_sku do
      sku { Faker::Code.ean }
    end
  end

  sequence :product_name do |n|
    products = [
      'Almond Butter Cookie',
      'Almond Cookie',
      'Almond Croissant',
      'Croissant',
      'Apple Butter Scone',
      'Pear Danish',
      'Apple Cinnamon Muffin',
      'Apple Pumpkin Muffin'
    ]

    "#{products.sample} #{n}"
  end
end
