# frozen_string_literal: true

class DetailedInvoiceReportGenerator
  include Generator
  composite_id bakery: :bakery, start_date: :date, end_date: :date

  def initialize(bakery, start_date, end_date)
    @bakery = bakery
    @start_date = start_date
    @end_date = end_date
  end

  def filename
    "Detailed-Invoice-Report-#{@start_date.iso8601}-to-#{@end_date.iso8601}.xlsx"
  end

  def generate
    DetailedInvoiceReportXlsx.new(@bakery, @start_date, @end_date).generate
  end
end
