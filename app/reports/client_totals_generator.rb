# frozen_string_literal: true

class ClientTotalsGenerator
  include Generator

  def self.find(global_id)
    bakery_id, date_string, type = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    date = Date.iso8601(date_string)
    type = type
    new(bakery, date, type)
  end

  def initialize(bakery, date, type)
    @bakery = bakery
    @date = date.to_date
    @type = type
  end

  def id
    "#{@bakery.id}_#{@date.iso8601}_#{@type}_clients"
  end

  def filename
    if @type == "daily"
      "DailyClientTotalsReport-#{@date.iso8601}.xlsx"
    else
      "WeeklyClientTotalsReport-#{@date.iso8601}.xlsx"
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
