# frozen_string_literal: true

class ClientTotalGenerator
  include Generator
  composite_id bakery: :bakery, start_date: :date, end_date: :date

  def initialize(bakery, start_date, end_date)
    @bakery = bakery
    @start_date = start_date.to_date
    @end_date = end_date.to_date
  end

  def filename
    "Client-Totals-#{@start_date.iso8601}-to-#{@end_date.iso8601}.xlsx"
  end

  def generate
    ClientTotalXlsx.new(@bakery, @start_date, @end_date).generate
  end
end
