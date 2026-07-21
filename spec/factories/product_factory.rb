# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  product_type    :integer          not null
#  weight          :decimal(, )      not null
#  unit            :integer          not null
#  description     :text
#  over_bake       :decimal(, )      default(0.0), not null
#  motherdough_id  :integer
#  inclusion_id    :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  base_price      :decimal(, )      not null
#  bakery_id       :integer          not null
#  sku             :string
#  legacy_id       :string
#  total_lead_days :integer          not null
#  batch_recipe    :boolean          default(FALSE)
#  removed         :boolean          default(FALSE)
#  graph_data      :json
#

FactoryBot.define do
  factory :product do
    name { generate(:product_name) }
    product_type { Product.product_types.keys.sample }
    description { Faker::Lorem.sentence(word_count: 1) }
    weight { Faker::Number.decimal(l_digits: 0, r_digits: 3) }
    unit { Product.units.keys.sample }
    over_bake { Faker::Number.decimal(l_digits: 1, r_digits: 1) }
    base_price { Faker::Number.decimal(l_digits: 2) }
    bakery { create(:bakery) }
    # Mirrors the on_vienn_pick backfill migration ran for existing data --
    # keeps every existing vienoisserie-product spec on the Vienn Pick without
    # having to set the flag explicitly everywhere.
    on_vienn_pick { product_type == "vienoisserie" }

    transient do
      force_total_lead_days { 2 }
    end

    trait :with_inclusion do
      inclusion { create(:recipe_inclusion, bakery: bakery, lead_days: force_total_lead_days) }
    end

    trait :with_motherdough do
      motherdough { create(:recipe_motherdough, bakery: bakery, lead_days: force_total_lead_days) }
    end

    trait :with_recipe_items do
      inclusion { create(:recipe, :with_ingredients, bakery: bakery) }
      motherdough { create(:recipe_motherdough, :with_nested_recipes, bakery: bakery) }
    end

    trait :with_sku do
      sku { Faker::Code.ean }
    end
  end

  sequence :product_name do |n|
    products = [
      "Almond Butter Cookie",
      "Almond Cookie",
      "Almond Croissant",
      "Croissant",
      "Apple Butter Scone",
      "Pear Danish",
      "Apple Cinnamon Muffin",
      "Pumpkin Muffin"
    ]

    "#{products.sample} #{n}"
  end
end
