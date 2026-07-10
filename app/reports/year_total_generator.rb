# frozen_string_literal: true

class YearTotalGenerator
  include Generator
  composite_id bakery: :bakery, year: :string

  def initialize(bakery, year)
    @bakery = bakery
    @year = year
  end

  def filename
    "year_total_#{@year}.xlsx"
  end

  def generate
    YearTotalXlsx.new(@bakery, @year).generate
  end
end
