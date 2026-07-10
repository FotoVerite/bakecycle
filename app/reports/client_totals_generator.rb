# frozen_string_literal: true

class ClientTotalsGenerator
  include Generator
  composite_id bakery: :bakery, date: :date, type: :string

  def initialize(bakery, date, type)
    @bakery = bakery
    @date = date.to_date
    @type = type
  end

  def filename
    if @type == "daily"
      "Daily-Client-Totals-#{@date.iso8601}.xlsx"
    else
      "Weekly-Client-Totals-#{@date.iso8601}.xlsx"
    end
  end

  def generate
    if @type == "daily"
      DailyClientTotalsXlsx.new(@bakery, @date).generate
    else
      WeeklyClientTotalsXlsx.new(@bakery, @date).generate
    end
  end
end
