# frozen_string_literal: true

class YearTotalGenerator
  include Generator

  def self.find(global_id)
    bakery_id, year = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    new(bakery, year)
  end

  def initialize(bakery, year)
    @bakery = bakery
    @year = year
  end

  def id
    "#{@bakery.id}_#{@year}"
  end

  def filename
    "year_total_#{@year}.xlsx"
  end

  def generate
    YearTotalXlsx.new(@bakery, @year).generate
  end
end
