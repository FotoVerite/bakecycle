# frozen_string_literal: true

class SortedPackListGenerator
  include Generator
  composite_id bakery: :bakery, date: :date

  def initialize(bakery, date)
    @bakery = bakery
    @date = date.to_date
  end

  def filename
    "Sorted-Pack-List-#{@date.iso8601}.xlsx"
  end

  def generate
    SortedPackListXlsx.new(@bakery, @date).generate
  end
end
