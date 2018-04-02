# == Schema Information
#
# Table name: ingredients
#
#  id              :integer          not null, primary key
#  name            :string
#  description     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  bakery_id       :integer          not null
#  legacy_id       :string
#  ingredient_type :string           default("other"), not null
#  vendor_id       :integer
#  current_amount  :decimal(, )      default(0.0), not null
#  cost_per_gram   :decimal(, )
#

class Ingredient < ApplicationRecord
  extend AlphabeticalOrder

  attr_accessor :dirty, :cost, :cost_over_time_vendor_id

  INGREDIENT_TYPES = %w[flour salt yeast sugar hydration eggs fats other].freeze

  has_many :recipe_items, as: :inclusionable, class_name: "RecipeItem", dependent: :destroy, inverse_of: :inclusionable
  has_many :ingredient_prices_over_time, -> { order("created_at DESC") }, dependent: :destroy, inverse_of: :ingredient
  has_many :buy_orders, dependent: :destroy
  has_one :todays_buy_order, lambda {
                               where("created_at between ? and ?",
                                Time.zone.today.beginning_of_day,
                                Time.zone.today.end_of_day)
                             }, class_name: "BuyOrder", inverse_of: :ingredients

  belongs_to :bakery

  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery_id }
  validates :description, length: { maximum: 500 }
  validates :ingredient_type,
            presence: true,
            inclusion: { in: INGREDIENT_TYPES }
  validates :bakery, presence: true

  after_validation :record_costing_change
  before_destroy :check_for_recipes, prepend: true

  WEIGHT_UNITS = [
    "gallons",
    "grams",
    "kilograms",
    "pounds",
    "table spoons",
    "tea spoons",
    "units"
  ].freeze

  def self.policy_class
    ProductPolicy
  end

  def total_lead_days
    0
  end

  def cost_by_vendor(vendor)
    ingredient_prices_over_time.find_by(vendor_id: vendor.id).try(:cost_per_unit) || 0
  end

  private

  def record_costing_change
    # We are tricking rails to run validation but setting updated_at in the form.
    return unless dirty == "true"
    ingredient_prices_over_time.create(
      vendor_id: cost_over_time_vendor_id,
      bakery_id: bakery_id,
      cost_per_unit: cost,
      weight_unit: weight_unit,
      conversion: conversion,
      cost_per_gram: cost.to_f / conversion.to_f
    )
  end

  def check_for_recipes
    return unless recipe_items.any?
    errors.add(:base, I18n.t(:ingredient_in_use))
    throw(:abort)
  end
end
