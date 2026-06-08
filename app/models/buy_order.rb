# frozen_string_literal: true

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

class BuyOrder < ApplicationRecord
  belongs_to :bakery
  belongs_to :ingredient
  belongs_to :vendor
  after_save :update_ingredient_cost

  def self.policy_class
    ProductPolicy
  end

  def update_ingredient_cost
    last_point = IngredientPricesOverTime.order("created_at DESC")
      .find_by(ingredient_id: ingredient_id, vendor_id: vendor_id)
    return unless last_point

    ingredient.update(cost_per_gram: last_point.cost_per_gram)
  end
end
