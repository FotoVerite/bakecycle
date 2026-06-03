class VipListGenerator
  include Generator

  def self.find(global_id)
    bakery_id, _date = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    new(bakery)
  end

  def initialize(bakery)
    @bakery = bakery
    @date = Time.zone.today
  end

  def id
    "#{@bakery.id}_#{@date.iso8601}_vip_list"
  end

  def filename
    "VipList-#{@date.iso8601}.xlsx"
  end


  def generate
    VipListXlsx.new(@bakery).generate
  end
end
