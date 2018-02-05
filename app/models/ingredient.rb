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
#  weight_unit     :string           default("grams")
#  conversion      :decimal(, )      default(1.0)
#

class Ingredient < ApplicationRecord
  extend AlphabeticalOrder

  attr_accessor :dirty, :cost, :cost_over_time_vendor_id

  INGREDIENT_TYPES = %w[flour salt yeast sugar hydration eggs fats other].freeze

  has_many :recipe_items, as: :inclusionable, class_name: "RecipeItem", dependent: :destroy, inverse_of: :inclusionable
  has_many :ingredient_prices_over_time, -> {order("created_at DESC")}

  belongs_to :bakery

  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery_id }
  validates :description, length: { maximum: 500 }
  validates :ingredient_type,
            presence: true,
            inclusion: { in: INGREDIENT_TYPES }
  validates :bakery, presence: true

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
    ingredient_prices_over_time.where(vendor_id: vendor.id).first || 0
  end


  private

  def record_costing_change
    return unless dirty?
    cost_per_gram = cost / conversion
    ingredient_prices_over_time.create(
      vendor_id: cost_over_time_vendor_id,
      bakery_id: bakery_id,
      cost_per_unit: cost,
      weight_unit: weight_unit,
      conversion: conversion,
      cost_per_gram: cost_per_gram
    )
  end

  def cost
    0
  end

  def check_for_recipes
    return unless recipe_items.any?
    errors.add(:base, I18n.t(:ingredient_in_use))
    throw(:abort)
  end
end
