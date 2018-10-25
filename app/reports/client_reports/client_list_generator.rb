class ClientListGenerator
  include GlobalID::Identification

  def self.find(global_id)
    bakery_id, type, throwAway = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    new(bakery, type)
  end

  def initialize(bakery, type)
    @bakery = bakery
    @type = type
    @date = Time.zone.today
  end

  def id
    "#{@bakery.id}_#{@type}_#{@date.iso8601}#ClientList"
  end

  def filename
    "ClientList_#{@type}_#{@date.iso8601}.xlsx"
  end

  def content_type
    "application/xlsx"
  end

  def generate
    ClientListXlsx.new(@bakery, @date, @type).generate
  end
end
