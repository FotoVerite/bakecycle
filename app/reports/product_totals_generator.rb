# frozen_string_literal: true

class ProductTotalsGenerator
  include Generator
  composite_id bakery: :bakery, date: :date, type: :string

  def initialize(bakery, date, type)
    @bakery = bakery
    @date = date.to_date
    @type = type
  end

  def filename
    if @type == "daily"
      "DailyProductTotalsReport-#{@date.iso8601}.xlsx"
    else
      "WeeklyProductTotalsReport-#{@date.iso8601}.xlsx"
    end
  end

  def generate
    if @type == "daily"
      DailyProductTotalsXlsx.new(@bakery, @date).generate
    else
      WeeklyProductTotalsXlsx.new(@bakery, @date).generate
    end
  end
end
