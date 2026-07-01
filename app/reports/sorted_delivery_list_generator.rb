# frozen_string_literal: true

class SortedDeliveryListGenerator
  include Generator

  def self.find(global_id)
    bakery_id, date_string = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    date = Date.iso8601(date_string)
    new(bakery, date)
  end

  def initialize(bakery, date)
    @bakery = bakery
    @date = date
  end

  def id
    "#{@bakery.id}_#{@date.iso8601}"
  end

  def filename
    "Sorted-Delivery-List-#{@date.to_date.iso8601}.xlsx"
  end

  def generate
    SortedDeliveryListXlsx.new(@bakery, @date).generate
  end
end
