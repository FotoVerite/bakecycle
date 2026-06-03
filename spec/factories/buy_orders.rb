# == Schema Information
#
# Table name: buy_orders
#
#  id            :integer          not null, primary key
#  vendor_id     :integer
#  ingredient_id :integer
#  bakery_id     :integer
#  amount        :decimal(, )      default(0.0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryBot.define do
  factory :buy_order do
    bakery { create(:bakery) }
    ingredient { create(:ingredient, bakery: bakery) }
    vendor { create(:vendor, bakery: bakery) }
  end
end
