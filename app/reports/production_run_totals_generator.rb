class ProductionRunTotalsGenerator
  include GlobalID::Identification

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
    "#{@bakery.id}_#{@date.iso8601}_#{@type}"
  end

  def filename
    if @type == "daily"
      "DailyProductionTotalsReport-#{@date.iso8601}.xlsx"
    else
      "WeeklyProductionTotalsReport-#{@date.iso8601}.xlsx"
    end
  end

  def content_type
    "application/xlsx"
  end

  def generate
    if @type == "daily"
      DailyProductionRunTotalsXlxs.new(@bakery, @date).generate
    else
      WeeklyProductionRunTotalsXlxs.new(@bakery, @date).generate
    end
  end
end
