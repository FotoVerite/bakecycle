FactoryGirl.define do
  factory :product do
    name { generate(:product_name) }
    product_type { Product.product_type_options.sample }
    description { Faker::Lorem.sentence(1) }
    weight { Faker::Number.decimal(0, 3) }
    unit { Product.unit_options.sample }
    extra_amount { Faker::Number.decimal(0, 3) }
    base_price { Faker::Number.decimal(2) }

    trait :with_inclusion do
      association :inclusion, factory: :recipe_inclusion
    end

    trait :with_motherdough do
      association :motherdough, factory: :recipe_motherdough
    end
  end

  sequence :product_name do |n|
    products = [
      "Almond Butter Cookie",
      "Almond Cookie",
      "Almond Croissant",
      "Almond Croissant",
      "Apple Butter Scone",
      "Apple Cardamom Danish",
      "Apple Cinnamon Muffin",
      "Apple Pumpkin Muffin"
    ]

    "#{products.sample} #{n}"
  end
end
