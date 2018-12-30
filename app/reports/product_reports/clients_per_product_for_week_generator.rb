class ClientsPerProductForWeekGenerator
  include GlobalID::Identification

  def self.find(global_id)
    bakery_id, throwAway = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    new(bakery)
  end

  def initialize(bakery)
    @bakery = bakery
    @date = Time.zone.today
  end

  def id
    "#{@bakery.id}_#{@date.iso8601}#ClientsPerProductForWeek"
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
