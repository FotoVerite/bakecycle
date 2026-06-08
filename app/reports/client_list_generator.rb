# frozen_string_literal: true

class ClientListGenerator
  include Generator

  def self.find(global_id)
    bakery_id, type, = global_id.split("_")
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

  def generate
    ClientListXlsx.new(@bakery, @date, @type).generate
  end
end
