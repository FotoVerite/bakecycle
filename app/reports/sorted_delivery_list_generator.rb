# frozen_string_literal: true

class SortedDeliveryListGenerator
  include Generator
  composite_id bakery: :bakery, date: :date

  def initialize(bakery, date)
    @bakery = bakery
    @date = date
  end

  def filename
    "Sorted-Delivery-List-#{@date.to_date.iso8601}.xlsx"
  end

  def generate
    SortedDeliveryListXlsx.new(@bakery, @date).generate
  end
end
