# frozen_string_literal: true

class PackListGenerator
  include Generator
  composite_id bakery: :bakery, date: :date

  def initialize(bakery, date)
    @bakery = bakery
    @date = date.to_date
  end

  def filename
    "Pack-List-#{@date.iso8601}.xlsx"
  end

  def generate
    PackListXlsx.new(@bakery, @date).generate
  end
end
