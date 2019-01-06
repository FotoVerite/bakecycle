class ClientsPerProductForWeekGenerator
  include GlobalID::Identification

  def self.find(global_id)
    bakery_id, date_string, throw_away = global_id.split("_")
    date = Date.iso8601(date_string)
    bakery = Bakery.find(bakery_id)
    new(bakery, date)
  end

  def initialize(bakery, date)
    @bakery = bakery
    @date = date.to_date
  end

  def id
    "#{@bakery.id}_#{@date.iso8601}_ClientsPerProductForWeek"
  end

  def filename
    "ClientsPerProductForWeek#{@date.iso8601}.xlsx"
  end

  def content_type
    "application/xlsx"
  end

  def generate
    ClientsPerProductForWeekXlsx.new(@bakery, @date).generate
  end
end
