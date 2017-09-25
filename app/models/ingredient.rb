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
#  cost            :decimal(, )      default(0.0), not null
#  current_amount  :decimal(, )      default(0.0), not null
#  weight_unit     :string
#  conversion      :decimal(, )      default(0.0)
#

class Ingredient < ApplicationRecord
  extend AlphabeticalOrder

  attr_accessor :dirty

  INGREDIENT_TYPES = %w[flour salt yeast sugar hydration eggs fats other].freeze

  has_many :recipe_items, as: :inclusionable, class_name: "RecipeItem"
  has_many :cost_over_times

  belongs_to :bakery

  validates :name, presence: true, length: { maximum: 150 }, uniqueness: { scope: :bakery_id }
  validates :description, length: { maximum: 500 }
  validates :ingredient_type,
            presence: true,
            inclusion: { in: INGREDIENT_TYPES }
  validates :bakery, presence: true

  before_destroy :check_for_recipes
  after_save :record_costing_change

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

  private

  def record_costing_change
    return unless cost_changed?
    cost_per_gram = cost / conversion
    cost_over_times.create(
      cost_per_unit: cost,
      weight_unit: weight_unit,
      conversion: conversion,
      cost_per_gram: cost_per_gram
    )
  end

  def check_for_recipes
    return unless recipe_items.any?
    errors.add(:base, I18n.t(:ingredient_in_use))
    false
  end
end
