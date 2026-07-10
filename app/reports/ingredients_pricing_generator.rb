# frozen_string_literal: true

class IngredientsPricingGenerator
  include Generator
  composite_id bakery: :bakery

  def initialize(bakery)
    @bakery = bakery
    @date = Time.zone.today
  end

  def filename
    "Ingredient-Pricing-#{@date.iso8601}.xlsx"
  end

  def generate
    IngredientsPricingXlsx.new(@bakery).generate
  end
end
