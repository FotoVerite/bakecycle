# frozen_string_literal: true

class ProductPricingGenerator
  include Generator
  composite_id bakery: :bakery

  def initialize(bakery)
    @bakery = bakery
    @date = Time.zone.today
  end

  def filename
    "Product-Pricing-#{@date.iso8601}.xlsx"
  end

  def generate
    ProductPricingXlsx.new(@bakery, @date).generate
  end
end
