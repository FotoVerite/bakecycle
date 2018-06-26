# == Schema Information
#
# Table name: ingredient_prices_over_times
#
#  id            :integer          not null, primary key
#  ingredient_id :integer
#  vendor_id     :integer
#  bakery_id     :integer
#  weight_unit   :string
#  conversion    :decimal(, )
#  cost_per_unit :decimal(, )
#  cost_per_gram :decimal(, )
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryBot.define do
  factory :ingredient_prices_over_time do
    cost_per_unit 1
    cost_per_gram 1
  end
end
