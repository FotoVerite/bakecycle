# frozen_string_literal: true

class BakeListGenerator
  include Generator
  composite_id bakery: :bakery, bake_date: :date

  def initialize(bakery, bake_date)
    @bakery = bakery
    @bake_date = bake_date.to_date
  end

  def filename
    "Bake-List-#{@bake_date.iso8601}.xlsx"
  end

  def generate
    BakeListXlsx.new(@bakery, @bake_date).generate
  end
end
