# frozen_string_literal: true

class ProductionRunTotalsGenerator
  include Generator
  composite_id bakery: :bakery, date: :date, type: :string

  def initialize(bakery, date, type)
    @bakery = bakery
    @date = date.to_date
    @type = type
  end

  def filename
    if @type == "daily"
      "Daily-Production-Totals-#{@date.iso8601}.xlsx"
    else
      "Weekly-Production-Totals-#{@date.iso8601}.xlsx"
    end
  end

  def generate
    if @type == "daily"
      DailyProductionRunTotalsXlsx.new(@bakery, @date).generate
    else
      WeeklyProductionRunTotalsXlsx.new(@bakery, @date).generate
    end
  end
end
