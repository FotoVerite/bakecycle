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

class IngredientPricesOverTime < ApplicationRecord
  belongs_to :ingredient
  belongs_to :vendor

  before_create :check_if_information_is_new

  def check_if_information_is_new
    last_point = IngredientPricesOverTime.order("created_at DESC").find_by(vendor_id: vendor_id)
    throw(:abort) if last_point.cost_per_unit.to_f == cost_per_unit.to_f &&
        last_point.conversion == conversion &&
        last_point.weight_unit == weight_unit
  end
end
