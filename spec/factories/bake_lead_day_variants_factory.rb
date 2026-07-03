# frozen_string_literal: true

FactoryBot.define do
  factory :bake_lead_day_variant do
    product { create(:product) }
    client { create(:client, bakery: product.bakery) }
    bake_lead_days { 0 }
  end
end
