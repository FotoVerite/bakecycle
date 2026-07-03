# frozen_string_literal: true

class BakeListGenerator
  include Generator

  def self.find(global_id)
    bakery_id, date_string = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    date = Date.iso8601(date_string)
    new(bakery, date)
  end

  def initialize(bakery, bake_date)
    @bakery = bakery
    @bake_date = bake_date.to_date
  end

  def id
    "#{@bakery.id}_#{@bake_date.iso8601}_bake_list"
  end

  def filename
    "Bake-List-#{@bake_date.iso8601}.xlsx"
  end

  def generate
    BakeListXlsx.new(@bakery, @bake_date).generate
  end
end
