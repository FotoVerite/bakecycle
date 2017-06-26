class ProductionRunTotalsGenerator
  include GlobalID::Identification

  def self.find(global_id)
    bakery_id, date_string, type = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    start_date = Date.iso8601(date_string)
    type = type
    new(bakery, start_date, type)
  end

  def initialize(bakery, start_date, type)
    @bakery = bakery
    @start_date = start_date.to_date
    @type = type
  end

  def id
    "#{@bakery.id}_#{@start_date.iso8601}_#{@type}"
  end

  def filename
    if @type == "daily"
      "DailyProductionTotalsReport-#{@start_date.iso8601}.xlsx"
    else
      "WeeklyProductionTotalsReport-#{@start_date.iso8601}.xlsx"
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
