FactoryGirl.define do
  factory :ingredient do
    name { generate(:ingredient_name) }
    price { Faker::Number.decimal(3) }
    measure { Faker::Number.decimal(0, 3) }
    unit { Ingredient.unit_options.sample }
    ingredient_type { Ingredient.ingredient_type_options.sample }
    description { Faker::Lorem.sentence(1) }
  end

  sequence :ingredient_name do |n|
    ingredients = [
      'Almond flour',
      'Amaranth',
      'Baking Powder',
      'Baking Soda',
      'Black Sesame',
      'Break Flower Blend',
      'Butter, Sweet 83% High Fat',
      'Butter, Sweet AA',
      'Cherries, Sun Dried',
      'Chili Flakes',
      'Chives, 4oz',
      'Chocolate Chips',
      'Cocoa Nibs',
      'Cocoa Powder',
      'Coppa',
      'Coriander',
      'Corn Meal',
      'Cracked Oats',
      'Cracked Rye',
      'Water'
    ]
    "#{ingredients.sample} ##{n}"
  end
end
