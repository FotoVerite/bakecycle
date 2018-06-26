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
  attr_accessor :lowest_cost

  belongs_to :ingredient
  belongs_to :vendor

  before_create :check_if_information_is_new
  after_create :updated_ingredient
  validates :cost_per_unit, :cost_per_gram,  :numericality => true 

  scope :last_two_weeks, -> { where("created_at >= ?", Time.zone.today - 2.weeks) }

  def updated_ingredient
    ingredient.update(conversion: conversion, weight_unit: weight_unit)
  end

  # rubocop:disable Metrics/AbcSize

  def check_if_information_is_new
    last_point = IngredientPricesOverTime.order("created_at DESC")
      .find_by(vendor_id: vendor_id, ingredient_id: ingredient_id)
    return if last_point.blank?
    if last_point.created_at.to_date == Time.zone.today
      last_point.update(cost_per_unit: cost_per_unit, conversion: conversion, weight_unit: weight_unit)
      throw(:abort)
    end
    throw(:abort) if last_point.cost_per_unit.to_f == cost_per_unit.to_f &&
        last_point.conversion == conversion &&
        last_point.weight_unit == weight_unit
  end

  # rubocop:enable Metrics/AbcSize
end
